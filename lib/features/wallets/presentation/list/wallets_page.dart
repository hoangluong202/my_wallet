import 'package:flutter/material.dart';
import 'package:my_wallet/core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/wallet.dart';
import 'wallets_viewmodel.dart';
import 'wallets_app_bar.dart';
import 'wallet_summary_card.dart';
import 'wallet_card.dart';
import '../form/add_wallet_page.dart';
import '../form/wallet_form_page.dart';
import '../detail/wallet_detail_page.dart';
import '../history/wallet_history_page.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  late final WalletsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<WalletsViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          WalletsAppBar(onAddPressed: _onAddWallet),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ListenableBuilder(
                    listenable: _viewModel,
                    builder: (context, _) {
                      if (_viewModel.error == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _viewModel.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<int>(
                    stream: _viewModel.totalBalanceStream,
                    builder: (context, balanceSnapshot) {
                      return StreamBuilder<int>(
                        stream: _viewModel.walletsCountStream,
                        builder: (context, countSnapshot) {
                          return WalletSummaryCard(
                            walletsCount: countSnapshot.data ?? 0,
                            totalBalance: balanceSnapshot.data ?? 0,
                          );
                        },
                      );
                    },
                  ),
                  Expanded(
                    child: StreamBuilder<List<Wallet>>(
                      stream: _viewModel.walletsStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final wallets = snapshot.data ?? [];
                        if (wallets.isEmpty) return _buildEmptyState();

                        return ListView.builder(
                          itemCount: wallets.length,
                          padding: const EdgeInsets.only(bottom: 24),
                          itemBuilder: (context, index) {
                            final wallet = wallets[index];
                            return WalletCard(
                              wallet: wallet,
                              onTap: () => _onWalletTap(wallet),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onAddWallet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletPage()),
    );

    if (result != null && mounted) {
      final wallet = Wallet(
        id: UuidGenerator.generate(),
        name: result['name'],
        balance: result['balance'],
        createdAt: result['createdAt'],
        updatedAt: result['updatedAt'],
        iconCode: result['iconCode'],
      );

      await _viewModel.addWallet(wallet);
      if (mounted && _viewModel.error == null) {
        SuccessNotification.show(
          context: context,
          message: 'Wallet "${wallet.name}" added successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No wallets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first wallet',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _onWalletTap(Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletDetailPage(
          wallet: wallet,
          onEdit: () => _onEditWallet(wallet),
          onDelete: () => _onDeleteWallet(wallet),
          onHistory: () => _onViewHistory(wallet),
        ),
      ),
    );
  }

  void _onEditWallet(Wallet wallet) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletFormPage(wallet: wallet, isEditMode: true),
      ),
    );

    if (result != null && mounted) {
      final updatedWallet = Wallet(
        id: wallet.id,
        name: result['name'],
        balance: result['balance'],
        createdAt: wallet.createdAt,
        updatedAt: result['updatedAt'],
        iconCode: result['iconCode'],
      );

      await _viewModel.updateWallet(updatedWallet);
      if (mounted && _viewModel.error == null) {
        Navigator.pop(context); // Close detail page
        SuccessNotification.show(
          context: context,
          message: 'Wallet "${updatedWallet.name}" updated successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _onDeleteWallet(Wallet wallet) async {
    try {
      await _viewModel.deleteWallet(wallet.id);
      if (mounted && _viewModel.error == null) {
        SuccessNotification.show(
          context: context,
          message: 'Wallet "${wallet.name}" deleted successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorNotification.show(
          context: context,
          message: e.toString().replaceFirst('Exception: ', ''),
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _onViewHistory(Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletHistoryPage(wallet: wallet),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

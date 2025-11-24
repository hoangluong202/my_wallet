import 'package:flutter/material.dart';
import 'package:my_wallet/shared/widgets/notification_widget.dart';
import '../../../../app/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../viewmodels/wallets_viewmodel.dart';
import '../widgets/wallets_app_bar.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/wallet_card.dart';
import 'add_wallet_page.dart';
import 'wallet_form_page.dart';
import 'wallet_detail_page.dart';
import 'wallet_history_page.dart';

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
    _viewModel = WalletsViewModel(getIt<WalletRepository>());
    _viewModel.loadWallets();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              WalletsAppBar(
                onAddPressed: _onAddWallet,
                onSyncPressed: _onSyncToCloud,
                viewModel: _viewModel,
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_viewModel.error != null) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            'Error: ${_viewModel.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _viewModel.loadWallets,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return WalletSummaryCard(
                    walletsCount: _viewModel.walletsCount,
                    totalBalance: _viewModel.totalBalance,
                  );
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    if (_viewModel.isLoading) {
                      return const SizedBox.shrink();
                    }

                    if (_viewModel.wallets.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: _viewModel.loadWallets,
                      child: ListView.builder(
                        itemCount: _viewModel.wallets.length,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemBuilder: (context, index) {
                          final wallet = _viewModel.wallets[index];
                          return WalletCard(
                            wallet: wallet,
                            onTap: () => _onWalletTap(wallet),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        createdOn: result['createdOn'],
        lastUpdated: result['lastUpdated'],
        icon: result['icon'],
        iconColor: result['iconColor'],
      );

      await _viewModel.addWallet(wallet);
      if (mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Wallet "${wallet.name}" added successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    }
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
        createdOn: wallet.createdOn,
        lastUpdated: result['lastUpdated'],
        icon: result['icon'],
        iconColor: result['iconColor'],
      );

      await _viewModel.updateWallet(wallet, updatedWallet);
      if (mounted) {
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
    await _viewModel.deleteWallet(wallet.id);
    if (mounted) {
      SuccessNotification.show(
        context: context,
        message: 'Wallet "${wallet.name}" deleted successfully!',
        duration: const Duration(seconds: 2),
      );
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

  Future<void> _onSyncToCloud() async {
    try {
      const userId = '101'; // Replace with actual user ID from authentication

      await _viewModel.bidirectionalSync(userId);

      if (mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Sync completed: Local → Cloud → Local',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorMessage('Sync failed: $e');
      }
    }
  }
}

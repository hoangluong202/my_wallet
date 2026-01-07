import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import 'wallets_viewmodel.dart';
import 'wallets_app_bar.dart';
import 'wallet_summary_card.dart';
import 'wallet_card.dart';
import '../form/wallet_form_page.dart';
import '../detail/wallet_detail_page.dart';
import '../model/wallet_view_data.dart';

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
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<List<WalletViewData>>(
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

  void _onAddWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletPage()),
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

  void _onWalletTap(WalletViewData wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletDetailPage(walletId: wallet.id),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/header/detail_header.dart';
import 'wallets_viewmodel.dart';
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
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddWallet,
        tooltip: 'Add wallet',
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Wallets',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: StreamBuilder<List<WalletViewData>>(
                stream: _viewModel.walletsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final wallets = snapshot.data!;
                  final totalBalance = wallets.fold<int>(
                    0,
                    (sum, wallet) => sum + wallet.balance,
                  );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    children: [
                      WalletSummaryCard(
                        walletsCount: wallets.length,
                        totalBalance: totalBalance,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Your wallets',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${wallets.length} total',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (wallets.isEmpty)
                        _buildEmptyState()
                      else
                        ...wallets.map(
                          (wallet) => WalletCard(
                            wallet: wallet,
                            onTap: () => _onWalletTap(wallet),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 52,
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

import 'package:flutter/material.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/wallet.dart';
import '../viewmodels/wallets_viewmodel.dart';
import '../widgets/wallets_app_bar.dart';
import '../widgets/wallet_summary_card.dart';
import '../widgets/wallet_card.dart';
import 'wallet_detail_page.dart';

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
    _viewModel = WalletsViewModel();
    _viewModel.initializeWallets();
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
              WalletsAppBar(onAddPressed: _onAddWallet),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
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
                    return ListView.builder(
                      itemCount: _viewModel.wallets.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final wallet = _viewModel.wallets[index];
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
    );
  }

  void _onAddWallet() {
    Navigator.pushNamed(context, AppRouter.addWallet).then((result) {
      if (result == true) {
        context.showSuccessMessage('Wallet created successfully!');
      }
    });
  }

void _onWalletTap(Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletDetailPage(
          wallet: wallet,
          onEdit: () {
            Navigator.pop(context); // Close detail page first
            _onEditWallet(wallet);
          },
          onDelete: () => _viewModel.deleteWallet(wallet.id),
          onHistory: () {
            Navigator.pop(context); // Close detail page first
            _onViewHistory(wallet);
          },
        ),
      ),
    );
  }

  void _onEditWallet(Wallet wallet) {
    Navigator.pushNamed(
      context,
      AppRouter.editWallet,
      arguments: EditWalletArguments(
        walletName: wallet.name,
        balance: wallet.balance,
        currency: 'VND (₫)',
      ),
    ).then((result) {
      if (result == true) {
        context.showSuccessMessage(
          'Wallet "${wallet.name}" updated successfully!',
        );
      }
    });
  }

  void _onViewHistory(Wallet wallet) {
    Navigator.pushNamed(
      context,
      AppRouter.walletHistory,
      arguments: wallet.name,
    );
  }

  Future<void> _onDeleteWallet(Wallet wallet) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Wallet?',
      content:
          'Are you sure you want to delete this wallet? '
          'All transactions associated with this wallet will also be deleted. '
          'This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed == true && mounted) {
      _viewModel.deleteWallet(wallet.id);
      Navigator.pop(context); // Close detail page
      context.showSuccessMessage(
        'Wallet "${wallet.name}" deleted successfully!',
      );
    }
  }
}

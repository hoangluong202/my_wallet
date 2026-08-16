import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:my_wallet/features/wallets/presentation/form/transfer_money_page.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/header/detail_header.dart';
import 'wallet_info_card.dart';
import '../model/wallet_view_data.dart';
import '../list/wallets_viewmodel.dart';
import '../../data/repositories/wallet_repository.dart';
import '../form/wallet_form_page.dart';
import '../../../../core/widgets/notification_widget.dart';

class WalletDetailPage extends StatefulWidget {
  final String walletId;

  const WalletDetailPage({super.key, required this.walletId});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  late final WalletsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WalletsViewModel(GetIt.instance<WalletRepository>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<WalletViewData?>(
          stream: _viewModel.watchWallet(widget.walletId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            final wallet = snapshot.data;
            if (wallet == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Wallet not found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This wallet may have been deleted',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                DetailHeader(
                  title: 'Wallet Details',
                  onBack: () => Navigator.pop(context),
                  onEdit: () => _navigateToEdit(context, wallet),
                  onDelete: () => _showDeleteConfirmation(context, wallet),
                ),
                _buildContent(context, wallet),
                const Expanded(child: SizedBox.expand()),
                _buildTransferButton(context, wallet),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTransferButton(BuildContext context, WalletViewData wallet) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton.icon(
            onPressed: () => _navigateToTransfer(context, wallet),
            style: FilledButton.styleFrom(
              backgroundColor: wallet.color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 22),
            label: const Text('Transfer money'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WalletViewData wallet) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [WalletInfoCard(wallet: wallet)],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    WalletViewData wallet,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditWalletPage(wallet: wallet)),
    );
  }

  Future<void> _navigateToTransfer(
    BuildContext context,
    WalletViewData wallet,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferMoneyPage(sourceWallet: wallet),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WalletViewData wallet,
  ) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Wallet?',
      content:
          'Are you sure you want to delete "${wallet.name}"?\n\n'
          'Note: You can only delete a wallet if there are no transactions using it. '
          'This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      await _deleteWallet(wallet.id);
    }
  }

  Future<void> _deleteWallet(String walletId) async {
    try {
      await _viewModel.deleteWallet(walletId);

      if (mounted) {
        Navigator.pop(context);
        SuccessNotification.show(
          context: context,
          message: 'Wallet deleted successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorNotification.show(
          context: context,
          message: 'Failed to delete wallet: $e',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}

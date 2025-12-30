import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/wallet.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../list/wallet_icon_section.dart';
import 'wallet_info_card.dart';
import 'wallet_action_buttons.dart';

class WalletDetailPage extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const WalletDetailPage({
    super.key,
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Wallet Details',
              onBack: () => Navigator.pop(context),
            ),
            _buildContent(context),
            const Expanded(child: SizedBox.expand()),
            WalletActionButtons(
              onEdit: onEdit,
              onHistory: onHistory,
              onDelete: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WalletIconSection(wallet: wallet),
            const SizedBox(height: 12),
            WalletInfoCard(wallet: wallet),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
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
      Navigator.pop(context); // Close detail page
      onDelete();
    }
  }
}

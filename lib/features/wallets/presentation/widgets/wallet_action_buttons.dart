import 'package:flutter/material.dart';
import 'wallet_action_button.dart';

class WalletActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onHistory;
  final VoidCallback onDelete;

  const WalletActionButtons({
    super.key,
    required this.onEdit,
    required this.onHistory,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            WalletActionButton(
              icon: Icons.edit,
              label: 'Edit',
              onPressed: onEdit,
              color: Colors.blue,
            ),
            WalletActionButton(
              icon: Icons.history,
              label: 'History',
              onPressed: onHistory,
              color: Colors.green,
            ),
            WalletActionButton(
              icon: Icons.delete_outline,
              label: 'Delete',
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

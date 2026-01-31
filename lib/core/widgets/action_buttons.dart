import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback? onHistory;
  final VoidCallback onDelete;
  final VoidCallback? onTransfer;

  const ActionButtons({
    super.key,
    required this.onEdit,
    this.onHistory,
    required this.onDelete,
    this.onTransfer,
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
            _buildActionButton(
              icon: Icons.edit,
              label: 'Edit',
              onPressed: onEdit,
              color: Colors.blue,
            ),
            if (onHistory != null)
              _buildActionButton(
                icon: Icons.history,
                label: 'History',
                color: Colors.green,
                onPressed: onHistory!,
              ),

            if (onTransfer != null)
              _buildActionButton(
                icon: Icons.compare_arrows,
                label: 'Transfer',
                color: Colors.purple,
                onPressed: onTransfer!,
              ),
            _buildActionButton(
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WalletsAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onSyncPressed;

  const WalletsAppBar({
    super.key,
    required this.onAddPressed,
    required this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Wallets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onSyncPressed,
          icon: const Icon(Icons.cloud_upload_outlined),
          tooltip: 'Sync to Cloud',
          style: IconButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

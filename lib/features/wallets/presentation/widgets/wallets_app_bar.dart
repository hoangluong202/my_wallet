import 'package:flutter/material.dart';

class WalletsAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const WalletsAppBar({
    super.key,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Wallets',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }
}
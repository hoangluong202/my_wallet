import 'package:flutter/material.dart';

class CustomFab extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Add transaction',
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 2,
      backgroundColor: colors.primary,
      foregroundColor: colors.onPrimary,
      splashColor: colors.onPrimary.withValues(alpha: 0.16),
      shape: CircleBorder(
        side: BorderSide(
          color: colors.surface,
          width: 3,
        ),
      ),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}

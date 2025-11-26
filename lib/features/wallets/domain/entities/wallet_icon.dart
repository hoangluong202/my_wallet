import 'package:flutter/material.dart';

class WalletIcon {
  final IconData icon;
  final Color color;
  final String label;

  const WalletIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletIcon &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          color == other.color;

  @override
  int get hashCode => icon.hashCode ^ color.hashCode;
}

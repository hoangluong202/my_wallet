import 'package:flutter/material.dart';

class WalletIconData {
  final IconData icon;
  final Color color;
  final String label;

  const WalletIconData({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletIconData &&
          runtimeType == other.runtimeType &&
          icon == other.icon &&
          color == other.color;

  @override
  int get hashCode => icon.hashCode ^ color.hashCode;
}

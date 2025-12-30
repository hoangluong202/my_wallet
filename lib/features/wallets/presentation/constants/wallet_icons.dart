import 'package:flutter/material.dart';

class WalletIconData {
  final IconData icon;
  final Color color;

  const WalletIconData({required this.icon, required this.color});
}

class WalletIcons {
  static const List<WalletIconData> icons = [
    WalletIconData(
      icon: Icons.error_outline,
      color: Color(0xFF9E9E9E), // Gray
    ),
    WalletIconData(
      icon: Icons.account_balance_wallet,
      color: Color(0xFF2196F3), // Blue
    ),
    WalletIconData(
      icon: Icons.credit_card,
      color: Color(0xFF9C27B0), // Purple
    ),
    WalletIconData(
      icon: Icons.account_balance,
      color: Color(0xFF1976D2), // Dark Blue
    ),
    WalletIconData(
      icon: Icons.savings,
      color: Color(0xFF4CAF50), // Green
    ),
    WalletIconData(
      icon: Icons.attach_money,
      color: Color(0xFF00C853), // Bright Green
    ),
    WalletIconData(
      icon: Icons.wallet,
      color: Color(0xFF00BCD4), // Cyan
    ),
    WalletIconData(
      icon: Icons.payment,
      color: Color(0xFFE91E63), // Pink
    ),
    WalletIconData(
      icon: Icons.money,
      color: Color(0xFFFFEB3B), // Yellow
    ),
    WalletIconData(
      icon: Icons.currency_exchange,
      color: Color(0xFFFF9800), // Orange
    ),
    WalletIconData(
      icon: Icons.paid,
      color: Color(0xFF66BB6A), // Light Green
    ),
    WalletIconData(
      icon: Icons.point_of_sale,
      color: Color(0xFF009688), // Teal
    ),
    WalletIconData(
      icon: Icons.shopping_bag,
      color: Color(0xFFF44336), // Red
    ),
    WalletIconData(
      icon: Icons.store,
      color: Color(0xFFFF5252), // Bright Red
    ),
    WalletIconData(
      icon: Icons.local_atm,
      color: Color(0xFF607D8B), // Blue Gray
    ),
    WalletIconData(
      icon: Icons.monetization_on,
      color: Color(0xFFFDD835), // Dark Yellow
    ),
    WalletIconData(
      icon: Icons.confirmation_number,
      color: Color(0xFFBA68C8), // Light Purple
    ),
    WalletIconData(
      icon: Icons.business_center,
      color: Color(0xFF795548), // Brown
    ),
    WalletIconData(
      icon: Icons.work,
      color: Color(0xFF455A64), // Dark Gray
    ),
    WalletIconData(
      icon: Icons.school,
      color: Color(0xFF42A5F5), // Light Blue
    ),
    WalletIconData(
      icon: Icons.home,
      color: Color(0xFFFF6D00), // Bright Orange
    ),
  ];

  static WalletIconData getIconByCodePoint(int codePoint) {
    final index = icons.indexWhere(
      (iconData) => iconData.icon.codePoint == codePoint,
    );
    return index != -1 ? icons[index] : icons[0];
  }
}

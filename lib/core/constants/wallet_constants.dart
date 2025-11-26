import 'package:flutter/material.dart';
import '../../features/wallets/domain/entities/wallet_icon.dart';

class WalletConstants {
  static const String defaultCurrency = 'VND (₫)';
  static const String currencySymbol = '₫';

  static const double iconSize = 56.0;
  static const double iconSizeSmall = 48.0;

  // Wallet action colors
  static const walletActionColors = {
    'edit': Colors.blue,
    'history': Colors.green,
    'delete': Colors.red,
  };

  static const List<WalletIcon> availableIcons = [
    WalletIcon(icon: Icons.account_balance, color: Colors.blue, label: 'Bank'),
    WalletIcon(
      icon: Icons.account_balance_wallet,
      color: Colors.indigo,
      label: 'Wallet',
    ),
    WalletIcon(icon: Icons.savings, color: Colors.green, label: 'Savings'),
    WalletIcon(
      icon: Icons.mobile_friendly,
      color: Colors.pink,
      label: 'Mobile',
    ),
    WalletIcon(
      icon: Icons.currency_bitcoin,
      color: Colors.orange,
      label: 'Crypto',
    ),
    WalletIcon(icon: Icons.attach_money, color: Colors.amber, label: 'Cash'),
    WalletIcon(icon: Icons.credit_card, color: Colors.purple, label: 'Card'),
    WalletIcon(icon: Icons.card_giftcard, color: Colors.red, label: 'Gift'),
  ];
}

import 'package:flutter/material.dart';
import '../../features/wallets/domain/models/wallet_icon_data.dart';

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

  static const List<WalletIconData> availableIcons = [
    WalletIconData(
      icon: Icons.account_balance,
      color: Colors.blue,
      label: 'Bank',
    ),
    WalletIconData(
      icon: Icons.account_balance_wallet,
      color: Colors.indigo,
      label: 'Wallet',
    ),
    WalletIconData(icon: Icons.savings, color: Colors.green, label: 'Savings'),
    WalletIconData(
      icon: Icons.mobile_friendly,
      color: Colors.pink,
      label: 'Mobile',
    ),
    WalletIconData(
      icon: Icons.currency_bitcoin,
      color: Colors.orange,
      label: 'Crypto',
    ),
    WalletIconData(
      icon: Icons.attach_money,
      color: Colors.amber,
      label: 'Cash',
    ),
    WalletIconData(
      icon: Icons.credit_card,
      color: Colors.purple,
      label: 'Card',
    ),
    WalletIconData(icon: Icons.card_giftcard, color: Colors.red, label: 'Gift'),
  ];
}

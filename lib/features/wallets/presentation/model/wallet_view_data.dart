import 'package:flutter/material.dart';
import '../constants/wallet_icons.dart';
import '../../domain/wallet.dart';

class WalletViewData {
  final String id;
  final String name;
  final int balance;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletViewData({
    required this.id,
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletViewData.fromDomain(Wallet wallet) {
    WalletIconData walletIconData = WalletIcons.getIconByCodePoint(
      wallet.iconCode,
    );
    return WalletViewData(
      id: wallet.id,
      name: wallet.name,
      balance: wallet.balance,
      icon: walletIconData.icon,
      color: walletIconData.color,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
  }
  
  static WalletViewData empty() {
    return WalletViewData(
      id: '',
      name: '',
      balance: 0,
      icon: Icons.account_balance_wallet,
      color: Colors.grey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

import 'package:flutter/material.dart';

class Wallet {
  final String id;
  final String name;
  final double balance;
  final DateTime createdOn;
  final DateTime lastUpdated;
  final IconData icon;
  final Color iconColor;
  final bool isSynced;
  final bool isDeleted;

  const Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.createdOn,
    required this.lastUpdated,
    this.icon = Icons.account_balance_wallet,
    this.iconColor = Colors.blue,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    DateTime? createdOn,
    DateTime? lastUpdated,
    IconData? icon,
    Color? iconColor,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdOn: createdOn ?? this.createdOn,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

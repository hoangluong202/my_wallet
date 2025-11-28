import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  WalletModel({
    required super.id,
    required super.name,
    required super.balance,
    required super.createdOn,
    required super.lastUpdated,
    super.icon = Icons.account_balance_wallet,
    super.iconColor = Colors.blue,
    super.isSynced = false,
    super.isDeleted = false,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      createdOn: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['updatedAt'] as String),
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      iconColor: Color(json['iconColor'] as int),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'iconCode': icon.codePoint,
      'iconColor': iconColor.value,
      'createdAt': createdOn.toIso8601String(),
      'updatedAt': lastUpdated.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory WalletModel.fromDrift(WalletData data) {
    return WalletModel(
      id: data.id,
      name: data.name,
      balance: data.balance,
      createdOn: data.createdAt,
      lastUpdated: data.updatedAt,
      icon: IconData(data.iconCode, fontFamily: 'MaterialIcons'),
      iconColor: Color(data.iconColor),
      isSynced: data.isSynced,
      isDeleted: data.isDeleted,
    );
  }

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      id: wallet.id,
      name: wallet.name,
      balance: wallet.balance,
      createdOn: wallet.createdOn,
      lastUpdated: wallet.lastUpdated,
      icon: wallet.icon,
      iconColor: wallet.iconColor,
      isSynced: wallet.isSynced,
      isDeleted: wallet.isDeleted,
    );
  }
}

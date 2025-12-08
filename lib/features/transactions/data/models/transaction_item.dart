import 'package:flutter/material.dart';

enum TransactionType { income, expense, debt, loan }

class TransactionItem {
  final String id;
  final String description;
  final String category;
  final double amount;
  final TransactionType type;
  final IconData categoryIcon;
  final DateTime date;
  final String walletName;

  TransactionItem({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.type,
    required this.categoryIcon,
    required this.date,
    required this.walletName,
  });
}

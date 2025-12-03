import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionItem {
  final String description;
  final String category;
  final double amount;
  final TransactionType type;
  final IconData categoryIcon;
  final DateTime date;

  TransactionItem({
    required this.description,
    required this.category,
    required this.amount,
    required this.type,
    required this.categoryIcon,
    required this.date,
  });
}

import 'package:flutter/material.dart';
import '../../../categories/domain/category.dart';

class TransactionTypeStyle {
  final Color amountColor;
  final Color bgColor;
  final String label;
  final String amountPrefix;

  const TransactionTypeStyle({
    required this.amountColor,
    required this.bgColor,
    required this.label,
    required this.amountPrefix,
  });
}

class TransactionTypeConstants {
  static final Map<CategoryType, TransactionTypeStyle> styles = {
    CategoryType.income: const TransactionTypeStyle(
      amountColor: Color(0xFF2E7D32), // Colors.green.shade700
      bgColor: Color(0xFFE8F5E9), // Colors.green.shade50
      label: 'Income',
      amountPrefix: '+',
    ),
    CategoryType.expense: const TransactionTypeStyle(
      amountColor: Color(0xFFF44336), // Colors.red
      bgColor: Color(0xFFFFEBEE), // Colors.red.shade50
      label: 'Expense',
      amountPrefix: '-',
    ),
    CategoryType.debt: const TransactionTypeStyle(
      amountColor: Color(0xFFE65100), // Colors.orange.shade700
      bgColor: Color(0xFFFFF3E0), // Colors.orange.shade50
      label: 'Debt',
      amountPrefix: '+',
    ),
    CategoryType.loan: const TransactionTypeStyle(
      amountColor: Color(0xFF6A1B9A), // Colors.purple.shade700
      bgColor: Color(0xFFF3E5F5), // Colors.purple.shade50
      label: 'Loan',
      amountPrefix: '-',
    ),
  };

  static TransactionTypeStyle getStyle(CategoryType type) {
    return styles[type] ?? styles[CategoryType.expense]!;
  }
}

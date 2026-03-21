import 'package:flutter/material.dart';

import '../../domain/category.dart';

class CategoryTypeBadge extends StatelessWidget {
  final CategoryType type;
  final Color color;

  const CategoryTypeBadge({super.key, required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

extension CategoryTypeLabel on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.income:
        return 'Income';
      case CategoryType.debt:
        return 'Debt';
      case CategoryType.loan:
        return 'Loan';
    }
  }

  bool get isCredit => this == CategoryType.income || this == CategoryType.debt;
}

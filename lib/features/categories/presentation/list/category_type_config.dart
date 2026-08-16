import 'package:flutter/material.dart';

import '../../domain/category.dart';

class CategoryTypeConfig {
  const CategoryTypeConfig({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  static CategoryTypeConfig from(CategoryType type) {
    return switch (type) {
      CategoryType.expense => const CategoryTypeConfig(
        label: 'Expense',
        icon: Icons.trending_down_rounded,
        color: Color(0xFFE85D5D),
      ),
      CategoryType.income => const CategoryTypeConfig(
        label: 'Income',
        icon: Icons.trending_up_rounded,
        color: Color(0xFF2EAD72),
      ),
      CategoryType.debt => const CategoryTypeConfig(
        label: 'Debt',
        icon: Icons.south_west_rounded,
        color: Color(0xFF7B61D1),
      ),
      CategoryType.loan => const CategoryTypeConfig(
        label: 'Loan',
        icon: Icons.north_east_rounded,
        color: Color(0xFFE39435),
      ),
    };
  }
}

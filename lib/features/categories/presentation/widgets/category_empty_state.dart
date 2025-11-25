import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryEmptyState extends StatelessWidget {
  final CategoryType type;

  const CategoryEmptyState({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'No ${_getCategoryLabel(type).toLowerCase()} categories yet',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(CategoryType type) {
    const labels = {
      CategoryType.expense: 'Expense',
      CategoryType.income: 'Income',
      CategoryType.debt: 'Debt',
      CategoryType.loan: 'Loan',
    };
    return labels[type] ?? 'Category';
  }
}

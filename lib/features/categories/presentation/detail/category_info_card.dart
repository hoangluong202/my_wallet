import 'package:flutter/material.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/category.dart';
import '../constants/category_icons.dart';

class CategoryInfoCard extends StatelessWidget {
  final Category category;

  const CategoryInfoCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            'Type',
            _getCategoryTypeLabel(category.type),
            CategoryIcons.getIconByCodePoint(category.iconCode).color,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            'Created On',
            DateFormatter.formatDate(category.createdAt),
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            context,
            'Last Updated',
            DateFormatter.formatDuration(category.updatedAt),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _getCategoryTypeLabel(CategoryType type) {
    switch (type) {
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
}

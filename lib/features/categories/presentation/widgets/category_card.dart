import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryInfo(context)),
            const SizedBox(width: 8),
            _buildRightArrow(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, color: category.color, size: 22),
    );
  }

  Widget _buildCategoryInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _getCategoryTypeLabel(category.type),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  Widget _buildRightArrow() {
    return Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400);
  }
}

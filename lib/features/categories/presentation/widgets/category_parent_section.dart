import 'package:flutter/material.dart';

import '../model/category_view_data.dart';
import 'category_type_badge.dart';

class CategoryParentSection extends StatelessWidget {
  final CategoryViewData parentCategory;
  final VoidCallback onTap;

  const CategoryParentSection({
    super.key,
    required this.parentCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Parent Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _ParentCategoryCard(category: parentCategory, onTap: onTap),
      ],
    );
  }
}

class _ParentCategoryCard extends StatelessWidget {
  final CategoryViewData category;
  final VoidCallback onTap;

  const _ParentCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _CategoryIcon(category: category),
            const SizedBox(width: 10),
            Expanded(child: _CategoryInfo(category: category)),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final CategoryViewData category;

  const _CategoryIcon({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(category.icon, color: category.color, size: 20),
    );
  }
}

class _CategoryInfo extends StatelessWidget {
  final CategoryViewData category;

  const _CategoryInfo({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        CategoryTypeBadge(type: category.type, color: category.color),
      ],
    );
  }
}

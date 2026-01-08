import 'package:flutter/material.dart';
import '../model/category_view_data.dart';

class CategoryIconSection extends StatelessWidget {
  final CategoryViewData category;

  const CategoryIconSection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 40, color: category.color),
          ),
          const SizedBox(height: 16),
          Text(
            category.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

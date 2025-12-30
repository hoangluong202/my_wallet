import 'package:flutter/material.dart';
import '../../domain/category.dart';
import '../constants/category_icons.dart';

class CategoryIconSection extends StatelessWidget {
  final Category category;

  const CategoryIconSection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final iconData = CategoryIcons.getIconByCodePoint(category.iconCode);
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconData.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData.icon, size: 40, color: iconData.color),
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

import 'package:flutter/material.dart';
import '../../domain/category.dart';

class CategoryIconData {
  final IconData icon;
  final Color color;

  const CategoryIconData({required this.icon, required this.color});
}

class CategoryIcons {
  static const List<CategoryIconData> icons = [
    CategoryIconData(
      icon: Icons.fastfood,
      color: Color(0xFFFF5722), // Deep Orange
    ),
    CategoryIconData(
      icon: Icons.directions_car,
      color: Color(0xFF3F51B5), // Indigo
    ),
    CategoryIconData(
      icon: Icons.home,
      color: Color(0xFF4CAF50), // Green
    ),
    CategoryIconData(
      icon: Icons.local_grocery_store,
      color: Color(0xFFFFC107), // Amber
    ),
    CategoryIconData(
      icon: Icons.movie,
      color: Color(0xFFE91E63), // Pink
    ),
    CategoryIconData(
      icon: Icons.fitness_center,
      color: Color(0xFF9C27B0), // Purple
    ),
    CategoryIconData(
      icon: Icons.flight,
      color: Color(0xFF00BCD4), // Cyan
    ),
    CategoryIconData(
      icon: Icons.medical_services,
      color: Color(0xFFF44336), // Red
    ),
    CategoryIconData(
      icon: Icons.school,
      color: Color(0xFF8BC34A), // Light Green
    ),
    CategoryIconData(
      icon: Icons.shopping_bag,
      color: Color(0xFFFF9800), // Orange
    ),
  ];

  static CategoryIconData getIconByCodePoint(int codePoint) {
    final index = icons.indexWhere(
      (iconData) => iconData.icon.codePoint == codePoint,
    );
    return index != -1
        ? icons[index]
        : CategoryIconData(
            icon: Icons.error_outline,
            color: Color(0xFF9E9E9E), // Gray
          );
  }
}

class CategoryTypeIcons {
  static const Map<CategoryType, CategoryIconData> typeIcons = {
    CategoryType.expense: CategoryIconData(
      icon: Icons.remove_circle,
      color: Colors.red,
    ),
    CategoryType.income: CategoryIconData(
      icon: Icons.add_circle,
      color: Colors.green,
    ),
    CategoryType.debt: CategoryIconData(
      icon: Icons.account_balance,
      color: Colors.orange,
    ),
    CategoryType.loan: CategoryIconData(
      icon: Icons.savings,
      color: Colors.purple,
    ),
  };

  static CategoryIconData getIconByType(CategoryType type) {
    return typeIcons[type]!;
  }
}

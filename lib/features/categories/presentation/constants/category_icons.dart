import 'package:flutter/material.dart';

class CategoryIconData {
  final IconData icon;
  final Color color;

  const CategoryIconData({required this.icon, required this.color});
}

class CategoryIcons {
  static const List<CategoryIconData> icons = [
    CategoryIconData(
      icon: Icons.error_outline,
      color: Color(0xFF9E9E9E), // Gray
    ),
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

  /// Get icon data by codePoint
  static CategoryIconData getIconByCodePoint(int codePoint) {
    final index = icons.indexWhere(
      (iconData) => iconData.icon.codePoint == codePoint,
    );
    return index != -1 ? icons[index] : icons[0];
  }
}

import '../constants/category_icons.dart';
import '../../domain/category.dart';
import 'package:flutter/material.dart';

class CategoryViewData {
  final String id;
  final String name;
  final CategoryType type;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryViewData({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryViewData.fromDomain(Category category) {
    CategoryIconData iconData = CategoryIcons.getIconByCodePoint(
      category.iconCode,
    );
    return CategoryViewData(
      id: category.id,
      name: category.name,
      type: category.type,
      icon: iconData.icon,
      color: iconData.color,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }
}

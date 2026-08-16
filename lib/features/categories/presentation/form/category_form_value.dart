import 'package:flutter/material.dart';

class CategoryFormValue {
  const CategoryFormValue({
    required this.name,
    required this.icon,
    required this.parentCategoryId,
  });

  final String name;
  final IconData icon;
  final String? parentCategoryId;
}

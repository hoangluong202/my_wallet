import 'package:flutter/material.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.type,
    required super.createdAt,
    required super.updatedAt,
    super.isSynced = false,
    super.isDeleted = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }

  factory CategoryModel.fromDrift(CategoryData data) {
    return CategoryModel(
      id: data.id,
      name: data.name,
      icon: IconData(data.iconCode, fontFamily: 'MaterialIcons'),
      color: Color(data.iconColor),
      type: _categoryTypeFromString(data.type),
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
      isDeleted: data.isDeleted,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      isSynced: category.isSynced,
      isDeleted: category.isDeleted,
    );
  }

  static CategoryType _categoryTypeFromString(String type) {
    switch (type) {
      case 'expense':
        return CategoryType.expense;
      case 'income':
        return CategoryType.income;
      case 'debt':
        return CategoryType.debt;
      case 'loan':
        return CategoryType.loan;
      default:
        return CategoryType.expense;
    }
  }
}

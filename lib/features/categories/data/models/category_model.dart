import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.transactionCount,
    required super.amount,
    required super.type,
    required super.createdOn,
    required super.lastUpdated,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      transactionCount: json['transactionCount'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      createdOn: DateTime.parse(json['createdOn'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'colorValue': color.value,
      'transactionCount': transactionCount,
      'amount': amount,
      'type': type.name,
      'createdOn': createdOn.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      transactionCount: category.transactionCount,
      amount: category.amount,
      type: category.type,
      createdOn: category.createdOn,
      lastUpdated: category.lastUpdated,
    );
  }
}

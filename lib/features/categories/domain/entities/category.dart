import 'package:flutter/material.dart';

enum CategoryType { expense, income, debt, loan }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final CategoryType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    CategoryType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

String categoryTypeLabel(CategoryType type) {
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

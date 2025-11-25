import 'package:flutter/material.dart';

enum CategoryType { expense, income, debt, loan }

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int transactionCount;
  final double amount;
  final CategoryType type;
  final DateTime createdOn;
  final DateTime lastUpdated;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.transactionCount,
    required this.amount,
    required this.type,
    required this.createdOn,
    required this.lastUpdated,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? transactionCount,
    double? amount,
    CategoryType? type,
    DateTime? createdOn,
    DateTime? lastUpdated,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      transactionCount: transactionCount ?? this.transactionCount,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdOn: createdOn ?? this.createdOn,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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

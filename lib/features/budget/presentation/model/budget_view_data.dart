import 'package:flutter/material.dart';
import '../../../categories/domain/category.dart';
import '../../../categories/presentation/constants/category_icons.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../domain/budget.dart';

class BudgetViewData {
  final String id;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final CategoryType categoryType;
  final int estimatedAmount;
  final int spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetViewData({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.categoryType,
    required this.estimatedAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress => estimatedAmount > 0
      ? (spentAmount / estimatedAmount).clamp(0.0, 1.0)
      : 0.0;

  bool get isOverBudget => spentAmount > estimatedAmount;

  int get remainingAmount => estimatedAmount - spentAmount;

  factory BudgetViewData.fromDomain(Budget budget, {int spentAmount = 0}) {
    IconData icon = Icons.pie_chart;
    Color color = Colors.green;

    if (budget.category != null) {
      final iconData = CategoryIcons.getIconByCodePoint(
        budget.category!.iconCode,
      );
      icon = iconData.icon;
      color = iconData.color;
    }

    return BudgetViewData(
      id: budget.id,
      categoryId: budget.categoryId,
      categoryName: budget.category?.name ?? 'Unknown',
      categoryIcon: icon,
      categoryColor: color,
      categoryType: budget.category?.type ?? CategoryType.expense,
      estimatedAmount: budget.estimatedAmount,
      spentAmount: spentAmount,
      startDate: budget.startDate,
      endDate: budget.endDate,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  factory BudgetViewData.fromDomainWithCategory(
    Budget budget,
    CategoryViewData category, {
    int spentAmount = 0,
  }) {
    return BudgetViewData(
      id: budget.id,
      categoryId: budget.categoryId,
      categoryName: category.name,
      categoryIcon: category.icon,
      categoryColor: category.color,
      categoryType: category.type,
      estimatedAmount: budget.estimatedAmount,
      spentAmount: spentAmount,
      startDate: budget.startDate,
      endDate: budget.endDate,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }
}

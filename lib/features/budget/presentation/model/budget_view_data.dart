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

  double get spendingPercentage =>
      estimatedAmount > 0 ? spentAmount / estimatedAmount * 100 : 0.0;

  bool get isOverBudget => spentAmount > estimatedAmount;

  int get remainingAmount => estimatedAmount - spentAmount;

  int get totalDays => endDate.difference(startDate).inDays.clamp(1, 99999);

  int get daysRemaining {
    final today = DateTime.now();
    if (today.isAfter(endDate)) return 0;
    if (today.isBefore(startDate)) return totalDays;
    return endDate
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  bool get isNotStarted => DateTime.now().isBefore(startDate);

  double get dayProgress {
    if (isNotStarted) return 0.0;
    if (isExpired) return 1.0;
    final today = DateTime.now();
    final elapsed = today.difference(startDate).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

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

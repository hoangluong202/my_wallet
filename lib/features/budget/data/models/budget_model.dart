import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/budget.dart';
import '../../../categories/domain/category.dart';

class BudgetModel {
  static Budget toEntity(BudgetData data, {Category? category}) {
    return Budget(
      id: data.id,
      categoryId: data.categoryId,
      estimatedAmount: data.estimatedAmount,
      startDate: data.startDate,
      endDate: data.endDate,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      category: category,
    );
  }

  static List<Budget> toEntityList(
    List<BudgetData> dataList, {
    Map<String, Category> categoryMap = const {},
  }) {
    return dataList
        .map((d) => toEntity(d, category: categoryMap[d.categoryId]))
        .toList();
  }

  static BudgetsCompanion toCompanion(Budget budget) {
    return BudgetsCompanion(
      id: Value(budget.id),
      categoryId: Value(budget.categoryId),
      estimatedAmount: Value(budget.estimatedAmount),
      startDate: Value(budget.startDate),
      endDate: Value(budget.endDate),
      createdAt: Value(budget.createdAt),
      updatedAt: Value(budget.updatedAt),
    );
  }
}

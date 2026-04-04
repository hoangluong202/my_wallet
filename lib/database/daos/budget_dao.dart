import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/budgets_table.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<List<BudgetData>> getAllBudgets() {
    return (select(budgets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Stream<List<BudgetData>> watchAllBudgets() {
    return (select(budgets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<BudgetData?> getBudgetById(String id) {
    return (select(budgets)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<BudgetData?> watchBudgetById(String id) {
    return (select(budgets)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<List<BudgetData>> getBudgetsByCategory(String categoryId) {
    return (select(
      budgets,
    )..where((t) => t.categoryId.equals(categoryId))).get();
  }

  Future<int> insertBudget(BudgetsCompanion budget) {
    return into(budgets).insert(budget);
  }

  Future<bool> updateBudget(BudgetsCompanion budget) {
    return update(budgets).replace(budget);
  }

  Future<int> deleteBudget(String id) {
    return (delete(budgets)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllBudgets() {
    return delete(budgets).go();
  }
}

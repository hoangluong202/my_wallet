import '../../domain/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Stream<List<Budget>> watchAllBudgets();
  Future<Budget?> getBudgetById(String id);
  Stream<Budget?> watchBudgetById(String id);
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);
}

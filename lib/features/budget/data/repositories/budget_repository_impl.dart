import '../../../../database/app_database.dart';
import '../../../categories/domain/category.dart';
import '../../domain/budget.dart';
import '../models/budget_model.dart';
import 'budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _database;

  BudgetRepositoryImpl(this._database);

  // Helper: fetch all categories and build a lookup map
  Future<Map<String, Category>> _getCategoryMap() async {
    final categoryDataList = await _database.categoryDao.getAllCategories();
    return {
      for (final c in categoryDataList)
        c.id: Category(
          id: c.id,
          name: c.name,
          type: CategoryType.values.firstWhere(
            (e) => e.name == c.type,
            orElse: () => CategoryType.expense,
          ),
          iconCode: c.iconCode,
          description: c.description,
          parentCategoryId: c.parentCategoryId,
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        ),
    };
  }

  @override
  Future<List<Budget>> getAllBudgets() async {
    final dataList = await _database.budgetDao.getAllBudgets();
    final categoryMap = await _getCategoryMap();
    return BudgetModel.toEntityList(dataList, categoryMap: categoryMap);
  }

  @override
  Stream<List<Budget>> watchAllBudgets() {
    return _database.budgetDao.watchAllBudgets().asyncMap((dataList) async {
      final categoryMap = await _getCategoryMap();
      return BudgetModel.toEntityList(dataList, categoryMap: categoryMap);
    });
  }

  @override
  Future<Budget?> getBudgetById(String id) async {
    final data = await _database.budgetDao.getBudgetById(id);
    if (data == null) return null;
    final categoryMap = await _getCategoryMap();
    return BudgetModel.toEntity(data, category: categoryMap[data.categoryId]);
  }

  @override
  Stream<Budget?> watchBudgetById(String id) {
    return _database.budgetDao.watchBudgetById(id).asyncMap((data) async {
      if (data == null) return null;
      final categoryMap = await _getCategoryMap();
      return BudgetModel.toEntity(data, category: categoryMap[data.categoryId]);
    });
  }

  @override
  Future<void> addBudget(Budget budget) async {
    final companion = BudgetModel.toCompanion(budget);
    await _database.budgetDao.insertBudget(companion);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final companion = BudgetModel.toCompanion(budget);
    await _database.budgetDao.updateBudget(companion);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _database.budgetDao.deleteBudget(id);
  }
}

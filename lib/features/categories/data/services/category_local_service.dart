import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../models/category_model.dart';
import '../../domain/entities/category.dart';

abstract class CategoryLocalService {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type);
  Future<CategoryModel> getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryLocalServiceImpl implements CategoryLocalService {
  final AppDatabase _database;

  CategoryLocalServiceImpl(this._database);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final categories = await _database.categoryDao.getAllCategories();
    return categories.map((data) => CategoryModel.fromDrift(data)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    final typeString = _categoryTypeToString(type);
    final categories = await _database.categoryDao.getCategoriesByType(
      typeString,
    );
    return categories.map((data) => CategoryModel.fromDrift(data)).toList();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    final data = await _database.categoryDao.getCategoryById(id);
    if (data == null) {
      throw Exception('Category not found');
    }
    return CategoryModel.fromDrift(data);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final companion = CategoriesCompanion.insert(
      id: category.id,
      name: category.name,
      iconCode: category.icon.codePoint,
      iconColor: category.color.value,
      type: _categoryTypeToString(category.type),
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      isSynced: const Value(false), // Mark as not synced
      isDeleted: const Value(false),
    );
    await _database.categoryDao.insertCategory(companion);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final companion = CategoriesCompanion(
      id: Value(category.id),
      name: Value(category.name),
      iconCode: Value(category.icon.codePoint),
      iconColor: Value(category.color.value),
      type: Value(_categoryTypeToString(category.type)),
      createdAt: Value(category.createdAt),
      updatedAt: Value(category.updatedAt),
      isSynced: const Value(false), // Mark as not synced when updated
    );
    await _database.categoryDao.updateCategory(companion);
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Soft delete: mark as deleted instead of hard delete
    await _database.categoryDao.softDeleteCategory(id);
  }

  String _categoryTypeToString(CategoryType type) {
    switch (type) {
      case CategoryType.expense:
        return 'expense';
      case CategoryType.income:
        return 'income';
      case CategoryType.debt:
        return 'debt';
      case CategoryType.loan:
        return 'loan';
    }
  }
}

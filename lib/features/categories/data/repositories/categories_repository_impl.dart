import '../../domain/category.dart';
import 'categories_repository.dart';
import '../models/category_model.dart';
import '../../../../database/app_database.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final AppDatabase _database;

  CategoriesRepositoryImpl(this._database);

  @override
  Future<List<Category>> getCategories() async {
    final categoriesData = await _database.categoryDao.getAllCategories();
    return CategoryModel.toEntityList(categoriesData);
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _database.categoryDao.watchAllCategories().map(
      CategoryModel.toEntityList,
    );
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    final categoriesData = await _database.categoryDao.getCategoriesByType(
      type.toString().split('.').last,
    );
    return CategoryModel.toEntityList(categoriesData);
  }

  @override
  Stream<List<Category>> watchCategoriesByType(CategoryType type) {
    return _database.categoryDao
        .watchCategoriesByType(type.toString().split('.').last)
        .map(CategoryModel.toEntityList);
  }

  @override
  Stream<Category?> watchCategoryById(String id) {
    return _database.categoryDao
        .watchCategoryById(id)
        .map(
          (categoryData) => categoryData != null
              ? CategoryModel.toEntity(categoryData)
              : null,
        );
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final categoryData = await _database.categoryDao.getCategoryById(id);
    return categoryData != null ? CategoryModel.toEntity(categoryData) : null;
  }

  @override
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.toCompanion(category);
    await _database.categoryDao.insertCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.toCompanion(category);
    await _database.categoryDao.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    // Check if the category itself is being used in transactions
    var transactionCount = await _database.transactionDao
        .countTransactionsByCategory(id);

    if (transactionCount > 0) {
      throw Exception(
        'Cannot delete category. It is being used in $transactionCount transaction${transactionCount > 1 ? 's' : ''}.',
      );
    }

    // Get all categories to find children
    final allCategories = await getCategories();

    // Check if any child categories exist
    final children = allCategories
        .where((c) => c.parentCategoryId == id)
        .toList();

    // If has children, don't allow deletion
    if (children.isNotEmpty) {
      throw Exception(
        'Cannot delete category. It has ${children.length} sub-categor${children.length > 1 ? 'ies' : 'y'}. Please delete them first.',
      );
    }

    // If no transactions use this category or its children, delete it
    await _database.categoryDao.deleteCategory(id);
  }

  // NEW: Parent category methods
  @override
  Future<bool> hasChildCategory(String parentCategoryId) async {
    return _database.categoryDao.hasChild(parentCategoryId);
  }

  @override
  Future<Category?> getParentCategory(String childCategoryId) async {
    final parentData = await _database.categoryDao.getParentCategory(
      childCategoryId,
    );
    return parentData != null ? CategoryModel.toEntity(parentData) : null;
  }

  @override
  Future<void> addCategoryWithValidation(Category category) async {
    // Validate parent category if provided
    if (category.parentCategoryId != null) {
      await _validateParentCategory(category);
    }
    await addCategory(category);
  }

  @override
  Future<void> updateCategoryWithValidation(Category category) async {
    // Validate parent category if provided
    if (category.parentCategoryId != null) {
      await _validateParentCategory(category);
    }
    await updateCategory(category);
  }

  // NEW: Private validation method
  Future<void> _validateParentCategory(Category category) async {
    // 1. Check parent exists
    final parent = await _database.categoryDao.getCategoryById(
      category.parentCategoryId!,
    );
    if (parent == null) {
      throw Exception('Parent category not found');
    }

    // 2. Check parent is not a child itself (max 1 level deep: root -> child only)
    if (parent.parentCategoryId != null) {
      throw Exception(
        'Cannot create multi-level hierarchy. Parent category must be a root category',
      );
    }

    // 3. Check type matches
    final parentType = CategoryType.values.firstWhere(
      (e) => e.name == parent.type,
      orElse: () => CategoryType.expense,
    );
    if (category.type != parentType) {
      throw Exception('Child category type must match parent type');
    }
  }
}

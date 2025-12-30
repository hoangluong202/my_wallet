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
    await _database.categoryDao.deleteCategory(id);
  }
}

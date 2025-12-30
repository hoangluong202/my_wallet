import '../../domain/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
  Stream<List<Category>> watchCategories();
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Stream<List<Category>> watchCategoriesByType(CategoryType type);
  Future<Category?> getCategoryById(String id);
  Stream<Category?> watchCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

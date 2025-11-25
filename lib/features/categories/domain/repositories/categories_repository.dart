import '../entities/category.dart';

abstract class CategoriesRepository {
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(CategoryType type);
  Future<Category> getCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

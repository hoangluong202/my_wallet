import '../../domain/entities/category.dart';
import 'categories_repository.dart';
import '../services/category_local_service.dart';
import '../services/category_firebase_service.dart';
import '../models/category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoryLocalService localService;
  final CategoryFirebaseService firebaseService;

  CategoriesRepositoryImpl(this.localService, this.firebaseService);

  @override
  Future<List<Category>> getCategories() async {
    return await localService.getCategories();
  }

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    return await localService.getCategoriesByType(type);
  }

  @override
  Future<Category> getCategoryById(String id) async {
    return await localService.getCategoryById(id);
  }

  @override
  Future<void> addCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localService.addCategory(model);
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localService.updateCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localService.deleteCategory(id);
  }

  @override
  Future<void> syncToCloud(String userId) async {
    await firebaseService.syncCategoriesToCloud(userId);
  }

  @override
  Future<void> pullFromCloud(String userId) async {
    await firebaseService.syncCategoriesFromCloud(userId);
  }
}

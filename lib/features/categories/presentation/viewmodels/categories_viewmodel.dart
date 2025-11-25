import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart' as entity;
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';

class CategoriesViewModel extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;

  List<entity.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesViewModel(
    this._getCategoriesUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
  );

  List<entity.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<entity.Category> getCategoriesByType(entity.CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  int getCategoriesCountByType(entity.CategoryType type) {
    return getCategoriesByType(type).length;
  }

  double getTotalAmountByType(entity.CategoryType type) {
    return getCategoriesByType(type).fold(0.0, (sum, c) => sum + c.amount);
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _getCategoriesUseCase();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(entity.Category category) async {
    try {
      await _addCategoryUseCase(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(
    entity.Category oldCategory,
    entity.Category newCategory,
  ) async {
    try {
      await _updateCategoryUseCase(newCategory);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _deleteCategoryUseCase(id);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

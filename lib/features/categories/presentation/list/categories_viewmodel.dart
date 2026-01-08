import 'package:flutter/material.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/category.dart';
import '../model/category_view_data.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;

  CategoriesViewModel(this._repository);

  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  String? validateCategoryName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a category name';
    }

    if (value.trim().length < 2) {
      return 'Category name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Category name must be less than 50 characters';
    }

    return null;
  }

  Stream<List<CategoryViewData>> get categoriesStream =>
      _repository.watchCategories().map(
        (categories) => categories
            .map((category) => CategoryViewData.fromDomain(category))
            .toList(),
      );

  Stream<CategoryViewData?> getCategoryStream(String id) => _repository
      .watchCategoryById(id)
      .map(
        (category) =>
            category != null ? CategoryViewData.fromDomain(category) : null,
      );

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> addCategory(Category category) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.addCategory(category);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCategory(Category newCategory) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.updateCategory(newCategory);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deleteCategory(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }
}

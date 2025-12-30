import 'package:flutter/material.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/category.dart';

class CategoriesViewModel extends ChangeNotifier {
  final CategoriesRepository _repository;

  CategoriesViewModel(this._repository);

  String? _error;
  String? get error => _error;

  Stream<List<Category>> get categoriesStream => _repository.watchCategories();

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _handleError(Object e) {
    _error = e.toString();
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    try {
      await _repository.addCategory(category);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> updateCategory(Category newCategory) async {
    try {
      await _repository.updateCategory(newCategory);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart' as entity;
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/add_category_usecase.dart';
import '../../domain/usecases/update_category_usecase.dart';
import '../../domain/usecases/delete_category_usecase.dart';
import '../../domain/usecases/sync_categories_usecase.dart';

class CategoriesViewModel extends ChangeNotifier {
  final GetCategoriesUseCase _getCategoriesUseCase;
  final AddCategoryUseCase _addCategoryUseCase;
  final UpdateCategoryUseCase _updateCategoryUseCase;
  final DeleteCategoryUseCase _deleteCategoryUseCase;
  final SyncCategoriesUseCase _syncCategoriesUseCase;

  List<entity.Category> _categories = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _syncMessage;

  CategoriesViewModel(
    this._getCategoriesUseCase,
    this._addCategoryUseCase,
    this._updateCategoryUseCase,
    this._deleteCategoryUseCase,
    this._syncCategoriesUseCase,
  );

  List<entity.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get syncMessage => _syncMessage;

  List<entity.Category> getCategoriesByType(entity.CategoryType type) {
    return _categories.where((c) => c.type == type).toList();
  }

  int getCategoriesCountByType(entity.CategoryType type) {
    return getCategoriesByType(type).length;
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

  Future<void> syncToCloud(String userId) async {
    try {
      await _syncCategoriesUseCase.syncToCloud(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pullFromCloud(String userId) async {
    try {
      await _syncCategoriesUseCase.pullFromCloud(userId);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Bidirectional sync: Push local data to cloud (priority), then pull cloud data to local
  Future<void> bidirectionalSync(String userId) async {
    _isSyncing = true;
    _syncMessage = 'Starting sync...';
    _error = null;
    notifyListeners();

    try {
      // Step 1: Push local categories to cloud (local data has priority)
      _syncMessage = 'Uploading local data to cloud...';
      notifyListeners();

      await _syncCategoriesUseCase.syncToCloud(userId);

      // Step 2: Pull new/updated data from cloud to local
      _syncMessage = 'Downloading updates from cloud...';
      notifyListeners();

      await _syncCategoriesUseCase.pullFromCloud(userId);

      // Step 3: Reload local data to reflect all changes
      _syncMessage = 'Refreshing local data...';
      notifyListeners();

      await loadCategories();

      _syncMessage = 'Sync completed successfully!';
      notifyListeners();

      // Clear sync message after delay
      await Future.delayed(const Duration(seconds: 2));
      _syncMessage = null;
      notifyListeners();
    } catch (e) {
      _error = 'Sync failed: $e';
      _syncMessage = null;
      notifyListeners();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

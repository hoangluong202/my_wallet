import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../../domain/entities/category.dart';

abstract class CategoriesLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type);
  Future<CategoryModel> getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoriesLocalDataSourceImpl implements CategoriesLocalDataSource {
  final List<CategoryModel> _mockCategories = [];

  CategoriesLocalDataSourceImpl() {
    _initMockData();
  }

  void _initMockData() {
    _mockCategories.addAll([
      CategoryModel(
        id: '1',
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
        type: CategoryType.expense,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '2',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        type: CategoryType.expense,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '3',
        name: 'Salary',
        icon: Icons.account_balance,
        color: Colors.green,
        type: CategoryType.income,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '4',
        name: 'Credit Card',
        icon: Icons.credit_card,
        color: Colors.red,
        type: CategoryType.debt,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      CategoryModel(
        id: '5',
        name: 'Home Loan',
        icon: Icons.home,
        color: Colors.brown,
        type: CategoryType.loan,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockCategories);
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(CategoryType type) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories.where((c) => c.type == type).toList();
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockCategories.firstWhere((c) => c.id == id);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockCategories.add(category);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _mockCategories[index] = category;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockCategories.removeWhere((c) => c.id == id);
  }
}

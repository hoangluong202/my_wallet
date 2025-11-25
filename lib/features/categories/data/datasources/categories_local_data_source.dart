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
        transactionCount: 12,
        amount: 2450000,
        type: CategoryType.expense,
        createdOn: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: '2',
        name: 'Transport',
        icon: Icons.directions_car,
        color: Colors.blue,
        transactionCount: 8,
        amount: 1800000,
        type: CategoryType.expense,
        createdOn: DateTime.now().subtract(const Duration(days: 25)),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: '3',
        name: 'Salary',
        icon: Icons.account_balance,
        color: Colors.green,
        transactionCount: 1,
        amount: 35000000,
        type: CategoryType.income,
        createdOn: DateTime.now().subtract(const Duration(days: 20)),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: '4',
        name: 'Credit Card',
        icon: Icons.credit_card,
        color: Colors.red,
        transactionCount: 15,
        amount: 25000000,
        type: CategoryType.debt,
        createdOn: DateTime.now().subtract(const Duration(days: 15)),
        lastUpdated: DateTime.now(),
      ),
      CategoryModel(
        id: '5',
        name: 'Home Loan',
        icon: Icons.home,
        color: Colors.brown,
        transactionCount: 60,
        amount: 1500000000,
        type: CategoryType.loan,
        createdOn: DateTime.now().subtract(const Duration(days: 10)),
        lastUpdated: DateTime.now(),
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

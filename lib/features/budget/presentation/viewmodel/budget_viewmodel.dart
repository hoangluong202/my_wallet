import 'package:flutter/material.dart';
import '../../../categories/data/repositories/categories_repository.dart';
import '../../../categories/domain/category.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../../transactions/presentation/model/transaction_view_data.dart';
import '../../data/repositories/budget_repository.dart';
import '../../domain/budget.dart';
import '../form/budget_payload.dart';
import '../model/budget_view_data.dart';

class BudgetViewModel extends ChangeNotifier {
  final BudgetRepository _budgetRepository;
  final CategoriesRepository _categoriesRepository;
  final TransactionRepository _transactionRepository;

  BudgetViewModel(
    this._budgetRepository,
    this._categoriesRepository,
    this._transactionRepository,
  );

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  // ─── Streams ─────────────────────────────────────────────────────────────

  Stream<List<BudgetViewData>> watchAllBudgets() {
    return _budgetRepository.watchAllBudgets().asyncMap(_enrichBudgets);
  }

  /// A lightweight budget stream for screens that only need budget limits.
  ///
  /// Unlike [watchAllBudgets], this does not query transactions to calculate
  /// spending for every budget.
  Stream<List<BudgetViewData>> watchBudgetDefinitions() {
    return _budgetRepository.watchAllBudgets().map(
      (budgets) => budgets.map(BudgetViewData.fromDomain).toList(),
    );
  }

  Stream<BudgetViewData?> watchBudgetById(String id) {
    return _budgetRepository.watchBudgetById(id).asyncMap((budget) async {
      if (budget == null) return null;
      final enriched = await _enrichBudgets([budget]);
      return enriched.isNotEmpty ? enriched.first : null;
    });
  }

  /// Returns a live stream of transactions belonging to [budget]'s category
  /// (and all sub-categories) within the budget's date range.
  Stream<List<TransactionViewData>> watchBudgetTransactions(
    BudgetViewData budget,
  ) {
    final budgetStartDate = _startOfDay(budget.startDate);
    final budgetEndDate = _endOfDay(budget.endDate);
    return Stream.fromFuture(
      _resolveCategoryIds(budget.categoryId),
    ).asyncExpand((categoryIds) {
      return _transactionRepository
          .watchTransactionsByDateRange(budgetStartDate, budgetEndDate)
          .map(
            (txns) => txns
                .where((t) => categoryIds.contains(t.category.id))
                .map(TransactionViewData.fromDomain)
                .toList(),
          );
    });
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Returns the budget category ID plus all its direct child category IDs.
  Future<List<String>> _resolveCategoryIds(String categoryId) async {
    final children = await _categoriesRepository.getCategories().then(
      (all) => all
          .where((c) => c.parentCategoryId == categoryId)
          .map((c) => c.id)
          .toList(),
    );
    return [categoryId, ...children];
  }

  DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999, 999);

  Future<List<BudgetViewData>> _enrichBudgets(List<Budget> budgets) async {
    if (budgets.isEmpty) return const [];

    try {
      final categories = await _categoriesRepository.getCategories();
      final childIdsByParent = <String, List<String>>{};
      for (final category in categories) {
        final parentId = category.parentCategoryId;
        if (parentId != null) {
          childIdsByParent.putIfAbsent(parentId, () => []).add(category.id);
        }
      }

      final firstStart = budgets
          .map((budget) => _startOfDay(budget.startDate))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final lastEnd = budgets
          .map((budget) => _endOfDay(budget.endDate))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final transactions = await _transactionRepository
          .getTransactionsByDateRange(firstStart, lastEnd);

      return budgets.map((budget) {
        final categoryIds = {
          budget.categoryId,
          ...?childIdsByParent[budget.categoryId],
        };
        final start = _startOfDay(budget.startDate);
        final end = _endOfDay(budget.endDate);
        final spent = transactions
            .where(
              (transaction) =>
                  categoryIds.contains(transaction.category.id) &&
                  !transaction.transactionDate.isBefore(start) &&
                  !transaction.transactionDate.isAfter(end),
            )
            .fold<int>(0, (sum, transaction) => sum + transaction.amount);

        return BudgetViewData.fromDomain(budget, spentAmount: spent);
      }).toList();
    } catch (_) {
      return budgets.map(BudgetViewData.fromDomain).toList();
    }
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<bool> addBudget(BudgetPayload payload) async {
    _setLoading(true);
    _clearError();
    try {
      final budget = Budget(
        id: payload.id,
        categoryId: payload.categoryId,
        estimatedAmount: payload.estimatedAmount,
        startDate: _startOfDay(payload.startDate),
        endDate: _startOfDay(payload.endDate),
        createdAt: payload.createdAt,
        updatedAt: payload.updatedAt,
      );
      await _budgetRepository.addBudget(budget);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> addBudgets(List<BudgetPayload> payloads) async {
    _setLoading(true);
    _clearError();
    try {
      final budgets = payloads
          .map(
            (payload) => Budget(
              id: payload.id,
              categoryId: payload.categoryId,
              estimatedAmount: payload.estimatedAmount,
              startDate: _startOfDay(payload.startDate),
              endDate: _startOfDay(payload.endDate),
              createdAt: payload.createdAt,
              updatedAt: payload.updatedAt,
            ),
          )
          .toList();
      await _budgetRepository.addBudgets(budgets);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBudget(BudgetPayload payload) async {
    _setLoading(true);
    _clearError();
    try {
      final budget = Budget(
        id: payload.id,
        categoryId: payload.categoryId,
        estimatedAmount: payload.estimatedAmount,
        startDate: _startOfDay(payload.startDate),
        endDate: _startOfDay(payload.endDate),
        createdAt: payload.createdAt,
        updatedAt: payload.updatedAt,
      );
      await _budgetRepository.updateBudget(budget);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await _budgetRepository.deleteBudget(id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
      return false;
    }
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final parsed = int.tryParse(value.replaceAll(',', '').replaceAll('.', ''));
    if (parsed == null || parsed <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // ─── Category helpers ─────────────────────────────────────────────────────

  Stream<List<CategoryViewData>> watchExpenseCategories() {
    return _categoriesRepository
        .watchCategoriesByType(CategoryType.expense)
        .map(
          (cats) => cats.map((c) => CategoryViewData.fromDomain(c)).toList(),
        );
  }

  Stream<List<CategoryViewData>> watchAllCategories() {
    return _categoriesRepository.watchCategories().map(
      (cats) => cats.map((c) => CategoryViewData.fromDomain(c)).toList(),
    );
  }
}

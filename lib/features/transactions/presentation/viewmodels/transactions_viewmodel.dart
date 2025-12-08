import 'package:flutter/material.dart';
import '../../domain/entities/transaction.dart';
import '../../data/services/transaction_local_service.dart';
import '../../data/services/transaction_firebase_service.dart';

class TransactionsViewModel extends ChangeNotifier {
  final TransactionLocalService _transactionLocalService;
  final TransactionFirebaseService _transactionFirebaseService;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _syncMessage;

  // Filters
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Statistics
  double _totalAmount = 0.0;

  TransactionsViewModel(
    this._transactionLocalService,
    this._transactionFirebaseService,
  ) {
    loadTransactions();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get syncMessage => _syncMessage;
  double get totalAmount => _totalAmount;
  int get transactionsCount => _transactions.length;

  String? get selectedWalletId => _selectedWalletId;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  // Load all transactions
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _transactionLocalService.getAllTransactions();
      await _calculateTotalAmount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return await _transactionLocalService.getTransactionById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Create transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionLocalService.insertTransaction(transaction);
      await loadTransactions(); // Refresh after creation
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionLocalService.updateTransaction(transaction);
      await loadTransactions(); // Refresh after update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete transaction (soft delete)
  Future<void> deleteTransaction(String id) async {
    try {
      await _transactionLocalService.softDeleteTransaction(id);
      await loadTransactions(); // Refresh after deletion
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Hard delete transaction
  Future<void> permanentlyDeleteTransaction(String id) async {
    try {
      await _transactionLocalService.deleteTransaction(id);
      await loadTransactions(); // Refresh after deletion
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Filter by wallet
  Future<void> filterByWallet(String? walletId) async {
    _selectedWalletId = walletId;
    await _applyFilters();
  }

  // Filter by category
  Future<void> filterByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    await _applyFilters();
  }

  // Filter by type
  Future<void> filterByType(String? type) async {
    _selectedType = type;
    await _applyFilters();
  }

  // Filter by date range
  Future<void> filterByDateRange(DateTime? start, DateTime? end) async {
    _startDate = start;
    _endDate = end;
    await _applyFilters();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    _selectedWalletId = null;
    _selectedCategoryId = null;
    _selectedType = null;
    _startDate = null;
    _endDate = null;
    await loadTransactions();
  }

  // Apply filters
  Future<void> _applyFilters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Start with all transactions
      List<Transaction> filtered = await _transactionLocalService
          .getAllTransactions();

      // Apply wallet filter
      if (_selectedWalletId != null) {
        filtered = await _transactionLocalService.getTransactionsByWalletId(
          _selectedWalletId!,
        );
      }

      // Apply category filter
      if (_selectedCategoryId != null) {
        filtered = filtered
            .where((t) => t.categoryId == _selectedCategoryId)
            .toList();
      }

      // Apply type filter
      if (_selectedType != null) {
        final typeTransactions = await _transactionLocalService
            .getTransactionsByType(_selectedType!);
        final typeIds = typeTransactions.map((t) => t.id).toSet();
        filtered = filtered.where((t) => typeIds.contains(t.id)).toList();
      }

      // Apply date range filter
      if (_startDate != null && _endDate != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.transactionDate.isAfter(
                    _startDate!.subtract(const Duration(days: 1)),
                  ) &&
                  t.transactionDate.isBefore(
                    _endDate!.add(const Duration(days: 1)),
                  ),
            )
            .toList();
      }

      _transactions = filtered;
      await _calculateTotalAmount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate total amount
  Future<void> _calculateTotalAmount() async {
    if (_transactions.isEmpty) {
      _totalAmount = 0.0;
      return;
    }

    try {
      if (_selectedWalletId != null) {
        _totalAmount = await _transactionLocalService.getTotalAmountByWalletId(
          _selectedWalletId!,
        );
      } else if (_selectedCategoryId != null) {
        _totalAmount = await _transactionLocalService
            .getTotalAmountByCategoryId(_selectedCategoryId!);
      } else if (_startDate != null && _endDate != null) {
        _totalAmount = await _transactionLocalService.getTotalAmountByDateRange(
          _startDate!,
          _endDate!,
        );
      } else {
        _totalAmount = _transactions.fold(0.0, (sum, t) => sum + t.amount);
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // Search transactions by note
  Future<void> searchByNote(String query) async {
    if (query.isEmpty) {
      await loadTransactions();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _transactionLocalService.searchTransactionsByNote(
        query,
      );
      await _calculateTotalAmount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transactions by wallet
  Future<List<Transaction>> getTransactionsByWallet(String walletId) async {
    try {
      return await _transactionLocalService.getTransactionsByWalletId(walletId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      return await _transactionLocalService.getTransactionsByCategoryId(
        categoryId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _transactionLocalService.getTransactionsByDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get total amount by wallet
  Future<double> getTotalAmountByWallet(String walletId) async {
    try {
      return await _transactionLocalService.getTotalAmountByWalletId(walletId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Get total amount by category
  Future<double> getTotalAmountByCategory(String categoryId) async {
    try {
      return await _transactionLocalService.getTotalAmountByCategoryId(
        categoryId,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0.0;
    }
  }

  // Get unsynced transactions
  Future<List<Transaction>> getUnsyncedTransactions() async {
    try {
      return await _transactionLocalService.getUnsyncedTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Mark transaction as synced
  Future<void> markAsSynced(String id) async {
    try {
      await _transactionLocalService.markAsSynced(id);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Watch all transactions stream
  Stream<List<Transaction>> watchAllTransactions() {
    return _transactionLocalService.watchAllTransactions();
  }

  // Watch transactions by wallet stream
  Stream<List<Transaction>> watchTransactionsByWallet(String walletId) {
    return _transactionLocalService.watchTransactionsByWalletId(walletId);
  }

  // Watch transactions by category stream
  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId) {
    return _transactionLocalService.watchTransactionsByCategoryId(categoryId);
  }

  // Watch single transaction stream
  Stream<Transaction?> watchTransaction(String id) {
    return _transactionLocalService.watchTransactionById(id);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get transactions grouped by date
  Map<DateTime, List<Transaction>> getTransactionsGroupedByDate() {
    final Map<DateTime, List<Transaction>> grouped = {};

    for (final transaction in _transactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    // Sort each group by time (descending)
    grouped.forEach((date, transactions) {
      transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
    });

    return grouped;
  }

  // Get transactions grouped by month
  Map<String, List<Transaction>> getTransactionsGroupedByMonth() {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in _transactions) {
      final monthKey =
          '${transaction.transactionDate.year}-${transaction.transactionDate.month.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }

    // Sort each group by date (descending)
    grouped.forEach((month, transactions) {
      transactions.sort(
        (a, b) => b.transactionDate.compareTo(a.transactionDate),
      );
    });

    return grouped;
  }

  // Get income transactions
  List<Transaction> get incomeTransactions {
    return _transactions; // This needs category type info to filter properly
  }

  // Get expense transactions
  List<Transaction> get expenseTransactions {
    return _transactions; // This needs category type info to filter properly
  }

  /// Bidirectional sync: Push local data to cloud (priority), then pull cloud data to local
  Future<void> bidirectionalSync(String userId) async {
    _isSyncing = true;
    _syncMessage = 'Starting sync...';
    _error = null;
    notifyListeners();

    try {
      // Step 1: Push local transactions to cloud (local data has priority)
      _syncMessage = 'Uploading local data to cloud...';
      notifyListeners();

      await _transactionFirebaseService.syncTransactionsToCloud(userId);

      // Step 2: Pull new/updated data from cloud to local
      _syncMessage = 'Downloading updates from cloud...';
      notifyListeners();

      await _transactionFirebaseService.syncTransactionsFromCloud(userId);

      // Step 3: Reload local data to reflect all changes
      _syncMessage = 'Refreshing local data...';
      notifyListeners();

      await loadTransactions();

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
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

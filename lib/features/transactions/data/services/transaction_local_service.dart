import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionLocalService {
  // Basic CRUD
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<void> insertTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> softDeleteTransaction(String id);

  // Query by filters
  Future<List<Transaction>> getTransactionsByWalletId(String walletId);
  Future<List<Transaction>> getTransactionsByCategoryId(String categoryId);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<Transaction>> getTransactionsByType(String categoryType);

  // Statistics
  Future<double> getTotalAmountByWalletId(String walletId);
  Future<double> getTotalAmountByCategoryId(String categoryId);
  Future<double> getTotalAmountByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  // Search
  Future<List<Transaction>> searchTransactionsByNote(String query);

  // Sync operations
  Future<List<Transaction>> getUnsyncedTransactions();
  Future<List<Transaction>> getDeletedTransactions();
  Future<void> markAsSynced(String id);
  Future<void> markAsNotSynced(String id);

  // Watch streams
  Stream<List<Transaction>> watchAllTransactions();
  Stream<List<Transaction>> watchTransactionsByWalletId(String walletId);
  Stream<List<Transaction>> watchTransactionsByCategoryId(String categoryId);
  Stream<Transaction?> watchTransactionById(String id);
}

class TransactionLocalServiceImpl implements TransactionLocalService {
  final AppDatabase _database;

  TransactionLocalServiceImpl(this._database);

  // Basic CRUD Operations

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final transactionDataList = await _database.transactionDao
        .getAllTransactions();
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final transactionData = await _database.transactionDao.getTransactionById(
      id,
    );
    return transactionData != null
        ? TransactionModel.fromDrift(transactionData)
        : null;
  }

  @override
  Future<void> insertTransaction(Transaction transaction) async {
    await _database.transaction(() async {
      // Get current wallet balance
      final wallet = await _database.walletDao.getWalletById(
        transaction.walletId,
      );

      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Get category to determine transaction type
      final category = await _database.categoryDao.getCategoryById(
        transaction.categoryId,
      );

      if (category == null) {
        throw Exception('Category not found');
      }

      // Calculate new balance based on category type
      double newBalance = wallet.balance;

      if (category.type == 'income' || category.type == 'debt') {
        // Income: add to balance
        newBalance = wallet.balance + transaction.amount;
      } else if (category.type == 'expense' || category.type == 'loan') {
        // Expense: subtract from balance (check if sufficient)
        if (wallet.balance < transaction.amount) {
          throw Exception('Insufficient balance');
        }
        newBalance = wallet.balance - transaction.amount;
      }

      // Insert transaction
      final companion = _toInsertCompanion(transaction);
      await _database.transactionDao.insertTransaction(companion);

      // Update wallet balance
      await _database.walletDao.updateWalletBalance(
        transaction.walletId,
        newBalance,
      );
    });
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _database.transaction(() async {
      // Get old transaction to revert its effect on wallet
      final oldTransactionData = await _database.transactionDao
          .getTransactionById(transaction.id);

      if (oldTransactionData == null) {
        throw Exception('Transaction not found');
      }

      // Get old category
      final oldCategory = await _database.categoryDao.getCategoryById(
        oldTransactionData.categoryId,
      );

      if (oldCategory == null) {
        throw Exception('Old category not found');
      }

      // Get new category
      final newCategory = await _database.categoryDao.getCategoryById(
        transaction.categoryId,
      );

      if (newCategory == null) {
        throw Exception('New category not found');
      }

      // Get wallet
      final wallet = await _database.walletDao.getWalletById(
        transaction.walletId,
      );

      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Revert old transaction effect
      double newBalance = wallet.balance;

      if (oldCategory.type == 'income' || oldCategory.type == 'debt') {
        newBalance -= oldTransactionData.amount; // Remove old income
      } else if (oldCategory.type == 'expense' || oldCategory.type == 'loan') {
        newBalance += oldTransactionData.amount; // Restore old expense
      }

      // Apply new transaction effect
      if (newCategory.type == 'income' || newCategory.type == 'debt') {
        newBalance += transaction.amount; // Add new income
      } else if (newCategory.type == 'expense' || newCategory.type == 'loan') {
        if (newBalance < transaction.amount) {
          throw Exception('Insufficient balance');
        }
        newBalance -= transaction.amount; // Subtract new expense
      }

      // Update transaction
      final companion = _toCompanion(transaction, isSynced: false);
      await _database.transactionDao.updateTransaction(companion);

      // Update wallet balance
      await _database.walletDao.updateWalletBalance(
        transaction.walletId,
        newBalance,
      );
    });
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _database.transaction(() async {
      // Get transaction to revert its effect on wallet
      final transactionData = await _database.transactionDao.getTransactionById(
        id,
      );

      if (transactionData == null) {
        throw Exception('Transaction not found');
      }

      // Get category
      final category = await _database.categoryDao.getCategoryById(
        transactionData.categoryId,
      );

      if (category == null) {
        throw Exception('Category not found');
      }

      // Get wallet
      final wallet = await _database.walletDao.getWalletById(
        transactionData.walletId,
      );

      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Revert transaction effect on wallet
      double newBalance = wallet.balance;

      if (category.type == 'income') {
        newBalance -= transactionData.amount; // Remove income
      } else if (category.type == 'expense') {
        newBalance += transactionData.amount; // Restore expense
      } else if (category.type == 'debt' || category.type == 'loan') {
        newBalance += transactionData.amount; // Restore debt/loan
      }

      // Delete transaction
      await _database.transactionDao.deleteTransaction(id);

      // Update wallet balance
      await _database.walletDao.updateWalletBalance(
        transactionData.walletId,
        newBalance,
      );
    });
  }

  @override
  Future<void> softDeleteTransaction(String id) async {
    await _database.transaction(() async {
      // Get transaction to revert its effect on wallet
      final transactionData = await _database.transactionDao.getTransactionById(
        id,
      );

      if (transactionData == null) {
        throw Exception('Transaction not found');
      }

      // Get category
      final category = await _database.categoryDao.getCategoryById(
        transactionData.categoryId,
      );

      if (category == null) {
        throw Exception('Category not found');
      }

      // Get wallet
      final wallet = await _database.walletDao.getWalletById(
        transactionData.walletId,
      );

      if (wallet == null) {
        throw Exception('Wallet not found');
      }

      // Revert transaction effect on wallet
      double newBalance = wallet.balance;

      if (category.type == 'income' || category.type == 'debt') {
        newBalance -= transactionData.amount; // Remove income/debt
      } else if (category.type == 'expense' || category.type == 'loan') {
        newBalance += transactionData.amount; // Restore expense/loan
      }

      // Soft delete transaction
      await _database.transactionDao.softDeleteTransaction(id);

      // Update wallet balance
      await _database.walletDao.updateWalletBalance(
        transactionData.walletId,
        newBalance,
      );
    });
  }

  // Query by Filters

  @override
  Future<List<Transaction>> getTransactionsByWalletId(String walletId) async {
    final transactionDataList = await _database.transactionDao
        .getTransactionsByWalletId(walletId);
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    final transactionDataList = await _database.transactionDao
        .getTransactionsByCategoryId(categoryId);
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactionDataList = await _database.transactionDao
        .getTransactionsByDateRange(startDate, endDate);
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByType(String categoryType) async {
    // Get all categories of the specified type
    final categories = await _database.categoryDao.getCategoriesByType(
      categoryType,
    );
    final categoryIds = categories.map((c) => c.id).toList();

    if (categoryIds.isEmpty) {
      return [];
    }

    // Get all transactions for these categories
    final allTransactions = await getAllTransactions();
    return allTransactions
        .where((t) => categoryIds.contains(t.categoryId))
        .toList();
  }

  // Statistics

  @override
  Future<double> getTotalAmountByWalletId(String walletId) async {
    return await _database.transactionDao.getTotalAmountByWalletId(walletId);
  }

  @override
  Future<double> getTotalAmountByCategoryId(String categoryId) async {
    return await _database.transactionDao.getTotalAmountByCategoryId(
      categoryId,
    );
  }

  @override
  Future<double> getTotalAmountByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _database.transactionDao.getTotalAmountByDateRange(
      startDate,
      endDate,
    );
  }

  // Search

  @override
  Future<List<Transaction>> searchTransactionsByNote(String query) async {
    final transactionDataList = await _database.transactionDao
        .searchTransactions(query);
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  // Sync Operations

  @override
  Future<List<Transaction>> getUnsyncedTransactions() async {
    final transactionDataList = await _database.transactionDao
        .getUnsyncedTransactions();
    return transactionDataList
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<List<Transaction>> getDeletedTransactions() async {
    // This requires updating the DAO to get deleted transactions
    final allTransactions = await _database.transactionDao.getAllTransactions();
    return allTransactions
        .where((t) => t.isDeleted)
        .map((data) => TransactionModel.fromDrift(data))
        .toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _database.transactionDao.markTransactionAsSynced(id);
  }

  @override
  Future<void> markAsNotSynced(String id) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.transactions,
      )..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  // Watch Streams

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    return _database.transactionDao.watchAllTransactions().map(
      (list) => list.map((data) => TransactionModel.fromDrift(data)).toList(),
    );
  }

  @override
  Stream<List<Transaction>> watchTransactionsByWalletId(String walletId) {
    return _database.transactionDao
        .watchTransactionsByWalletId(walletId)
        .map(
          (list) =>
              list.map((data) => TransactionModel.fromDrift(data)).toList(),
        );
  }

  @override
  Stream<List<Transaction>> watchTransactionsByCategoryId(String categoryId) {
    return _database.transactionDao
        .watchTransactionsByCategoryId(categoryId)
        .map(
          (list) =>
              list.map((data) => TransactionModel.fromDrift(data)).toList(),
        );
  }

  @override
  Stream<Transaction?> watchTransactionById(String id) {
    return _database.transactionDao
        .watchTransactionById(id)
        .map((data) => data != null ? TransactionModel.fromDrift(data) : null);
  }

  // Helper Methods

  TransactionsCompanion _toCompanion(
    Transaction transaction, {
    bool? isSynced,
  }) {
    return TransactionsCompanion(
      id: Value(transaction.id),
      categoryId: Value(transaction.categoryId),
      walletId: Value(transaction.walletId),
      amount: Value(transaction.amount),
      note: Value(transaction.note),
      transactionDate: Value(transaction.transactionDate),
      createdAt: Value(transaction.createdAt),
      updatedAt: Value(transaction.updatedAt),
      isSynced: Value(isSynced ?? transaction.isSynced),
      isDeleted: Value(transaction.isDeleted),
    );
  }

  TransactionsCompanion _toInsertCompanion(Transaction transaction) {
    return TransactionsCompanion.insert(
      id: transaction.id,
      categoryId: transaction.categoryId,
      walletId: transaction.walletId,
      amount: transaction.amount,
      note: Value(transaction.note),
      transactionDate: transaction.transactionDate,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      isSynced: const Value(false),
      isDeleted: const Value(false),
    );
  }
}

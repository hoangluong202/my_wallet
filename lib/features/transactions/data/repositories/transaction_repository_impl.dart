import 'dart:async';
import 'package:drift/drift.dart';
import '../../domain/transaction.dart';
import '../../../wallets/domain/wallet.dart';
import '../../../categories/domain/category.dart';
import '../../../../database/app_database.dart';
import 'transaction_repository.dart';
import '../../presentation/form/transaction_payload.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  // Private helper methods to map TransactionJoinedModel to Transaction domain
  Transaction _mapToDomain(TransactionJoinedModel joinedData) {
    final wallet = Wallet(
      id: joinedData.wallet.id,
      name: joinedData.wallet.name,
      balance: joinedData.wallet.balance,
      iconCode: joinedData.wallet.iconCode,
      createdAt: joinedData.wallet.createdAt,
      updatedAt: joinedData.wallet.updatedAt,
    );

    // Convert string type to CategoryType enum
    final categoryType = CategoryType.values.firstWhere(
      (e) => e.name == joinedData.category.type,
      orElse: () => CategoryType.expense,
    );

    final category = Category(
      id: joinedData.category.id,
      name: joinedData.category.name,
      type: categoryType,
      iconCode: joinedData.category.iconCode,
      createdAt: joinedData.category.createdAt,
      updatedAt: joinedData.category.updatedAt,
    );

    return Transaction(
      id: joinedData.transaction.id,
      amount: joinedData.transaction.amount,
      note: joinedData.transaction.note,
      transactionDate: joinedData.transaction.transactionDate,
      wallet: wallet,
      category: category,
      createdAt: joinedData.transaction.createdAt,
      updatedAt: joinedData.transaction.updatedAt,
    );
  }

  List<Transaction> _mapToDomainList(
    List<TransactionJoinedModel> joinedDataList,
  ) {
    return joinedDataList.map(_mapToDomain).toList();
  }

  TransactionsCompanion _toCompanion(Transaction transaction) {
    return TransactionsCompanion(
      id: Value(transaction.id),
      categoryId: Value(transaction.category.id),
      walletId: Value(transaction.wallet.id),
      amount: Value(transaction.amount),
      note: Value(transaction.note),
      transactionDate: Value(transaction.transactionDate),
      createdAt: Value(transaction.createdAt),
      updatedAt: Value(transaction.updatedAt),
    );
  }

  TransactionsCompanion _payloadToCompanion(TransactionPayload payload) {
    return TransactionsCompanion(
      id: Value(payload.id),
      categoryId: Value(payload.categoryId),
      walletId: Value(payload.walletId),
      amount: Value(payload.amount),
      note: Value(payload.note),
      transactionDate: Value(payload.transactionDate),
      createdAt: Value(payload.createdAt),
      updatedAt: Value(payload.updatedAt),
    );
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final joinedDataList = await _database.transactionDao
          .getAllTransactions();
      return _mapToDomainList(joinedDataList);
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    try {
      return _database.transactionDao.watchAllTransactions().map(
        _mapToDomainList,
      );
    } catch (e) {
      throw Exception('Failed to watch transactions: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final joinedDataList = await _database.transactionDao
          .getTransactionsByDateRange(startDate, endDate);
      return _mapToDomainList(joinedDataList);
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  @override
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return _database.transactionDao
          .watchTransactionsByDateRange(startDate, endDate)
          .map(_mapToDomainList);
    } catch (e) {
      throw Exception('Failed to watch transactions by date range: $e');
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final joinedData = await _database.transactionDao.getTransactionById(id);
      return joinedData != null ? _mapToDomain(joinedData) : null;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  Stream<Transaction?> watchTransactionById(String id) {
    try {
      return _database.transactionDao
          .watchTransactionById(id)
          .map(
            (joinedData) =>
                joinedData != null ? _mapToDomain(joinedData) : null,
          );
    } catch (e) {
      throw Exception('Failed to watch transaction: $e');
    }
  }

  @override
  Future<String> createTransaction(TransactionPayload transaction) async {
    try {
      await _database.transactionDao.insertTransaction(
        _payloadToCompanion(transaction),
      );
      return transaction.id;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }
  
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _database.transactionDao.updateTransaction(
        _toCompanion(transaction),
      );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _database.transactionDao.deleteTransaction(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}

import 'dart:async';
import '../../domain/transaction.dart';
import '../../../../database/app_database.dart';
import '../models/transaction_model.dart';
import 'transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;

  TransactionRepositoryImpl(this._database);

  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final transactionDataList = await _database.transactionDao
          .getAllTransactions();
      return TransactionModel.toEntityList(transactionDataList);
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  @override
  Stream<List<Transaction>> watchAllTransactions() {
    try {
      return _database.transactionDao.watchAllTransactions().map(
        TransactionModel.toEntityList,
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
      final transactionDataList = await _database.transactionDao
          .getTransactionsByDateRange(startDate, endDate);
      return TransactionModel.toEntityList(transactionDataList);
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
          .map(TransactionModel.toEntityList);
    } catch (e) {
      throw Exception('Failed to watch transactions by date range: $e');
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final transactionData = await _database.transactionDao.getTransactionById(
        id,
      );
      return transactionData != null
          ? TransactionModel.toEntity(transactionData)
          : null;
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
            (transactionData) => transactionData != null
                ? TransactionModel.toEntity(transactionData)
                : null,
          );
    } catch (e) {
      throw Exception('Failed to watch transaction: $e');
    }
  }

  @override
  Future<String> createTransaction(Transaction transaction) async {
    try {
      await _database.transactionDao.insertTransaction(
        TransactionModel.toCompanion(transaction),
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
        TransactionModel.toCompanion(transaction),
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

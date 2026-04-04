import './../../domain/transaction.dart';
import '../../presentation/form/transaction_payload.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Stream<List<Transaction>> watchAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Stream<Transaction?> watchTransactionById(String id);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Stream<List<Transaction>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<String> createTransaction(TransactionPayload transaction);
  Future<void> updateTransaction(TransactionPayload transaction);
  Future<void> deleteTransaction(String id);

  // NEW: Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);
  Stream<List<Transaction>> watchTransactionsByCategory(String categoryId);

  // NEW: Get transactions by multiple category IDs within a date range
  Future<List<Transaction>> getTransactionsByCategoryIds(
    List<String> categoryIds,
    DateTime startDate,
    DateTime endDate,
  );

  // Chart data aggregation methods
  Future<Map<int, Map<String, int>>> getDailyIncomeExpenseByMonth(
    int year,
    int month,
  );
  Stream<Map<int, Map<String, int>>> watchDailyIncomeExpenseByMonth(
    int year,
    int month,
  );
  Future<Map<String, int>> getCategoryExpensesByMonth(int year, int month);
  Stream<Map<String, int>> watchCategoryExpensesByMonth(int year, int month);
}

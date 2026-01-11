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

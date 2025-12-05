import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/categories_table.dart';
import '../tables/wallets_table.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Categories, Wallets])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Get all transactions (excluding soft-deleted)
  Future<List<TransactionData>> getAllTransactions() async {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Get transaction by ID
  Future<TransactionData?> getTransactionById(String id) async {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Get transactions by wallet ID
  Future<List<TransactionData>> getTransactionsByWalletId(
    String walletId,
  ) async {
    return (select(transactions)
          ..where(
            (t) => t.walletId.equals(walletId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Get transactions by category ID
  Future<List<TransactionData>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    return (select(transactions)
          ..where(
            (t) => t.categoryId.equals(categoryId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Get transactions by date range
  Future<List<TransactionData>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return (select(transactions)
          ..where(
            (t) =>
                t.transactionDate.isBiggerOrEqualValue(startDate) &
                t.transactionDate.isSmallerOrEqualValue(endDate) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Insert transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) async {
    return into(transactions).insert(transaction);
  }

  // Update transaction
  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    return update(transactions).replace(transaction);
  }

  // Delete transaction (soft delete)
  Future<int> softDeleteTransaction(String id) async {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Delete transaction (hard delete)
  Future<int> deleteTransaction(String id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // Get transactions count (excluding soft-deleted)
  Future<int> getTransactionsCount() async {
    final query = selectOnly(transactions)
      ..where(transactions.isDeleted.equals(false))
      ..addColumns([transactions.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(transactions.id.count()) ?? 0;
  }

  // Get total amount by wallet ID
  Future<double> getTotalAmountByWalletId(String walletId) async {
    final query = selectOnly(transactions)
      ..where(
        transactions.walletId.equals(walletId) &
            transactions.isDeleted.equals(false),
      )
      ..addColumns([transactions.amount.sum()]);
    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }

  // Get total amount by category ID
  Future<double> getTotalAmountByCategoryId(String categoryId) async {
    final query = selectOnly(transactions)
      ..where(
        transactions.categoryId.equals(categoryId) &
            transactions.isDeleted.equals(false),
      )
      ..addColumns([transactions.amount.sum()]);
    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }

  // Get total amount by date range
  Future<double> getTotalAmountByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = selectOnly(transactions)
      ..where(
        transactions.transactionDate.isBiggerOrEqualValue(startDate) &
            transactions.transactionDate.isSmallerOrEqualValue(endDate) &
            transactions.isDeleted.equals(false),
      )
      ..addColumns([transactions.amount.sum()]);
    final result = await query.getSingleOrNull();
    return result?.read(transactions.amount.sum()) ?? 0.0;
  }

  // Watch all transactions (stream, excluding soft-deleted)
  Stream<List<TransactionData>> watchAllTransactions() {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // Watch transactions by wallet ID (stream)
  Stream<List<TransactionData>> watchTransactionsByWalletId(String walletId) {
    return (select(transactions)
          ..where(
            (t) => t.walletId.equals(walletId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // Search transactions by note
  Future<List<TransactionData>> searchTransactions(String query) async {
    return (select(transactions)
          ..where(
            (t) =>
                t.note.like('%$query%') &
                t.note.isNotNull() &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Get unsynced transactions
  Future<List<TransactionData>> getUnsyncedTransactions() async {
    return (select(transactions)
          ..where((t) => t.isSynced.equals(false) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  // Mark transaction as synced
  Future<int> markTransactionAsSynced(String id) async {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isSynced: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Watch transactions by category ID (stream)
  Stream<List<TransactionData>> watchTransactionsByCategoryId(
    String categoryId,
  ) {
    return (select(transactions)
          ..where(
            (t) => t.categoryId.equals(categoryId) & t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.transactionDate,
              mode: OrderingMode.desc,
            ),
          ]))
        .watch();
  }

  // Watch single transaction by ID (stream)
  Stream<TransactionData?> watchTransactionById(String id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }
}

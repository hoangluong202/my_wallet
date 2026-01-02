import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/categories_table.dart';
import '../tables/wallets_table.dart';

part 'transaction_dao.g.dart';

class TransactionJoinedModel {
  final TransactionData transaction;
  final CategoryData category;
  final WalletData wallet;

  TransactionJoinedModel({
    required this.transaction,
    required this.category,
    required this.wallet,
  });
}

@DriftAccessor(tables: [Transactions, Categories, Wallets])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Private helper methods to reduce code duplication
  JoinedSelectStatement _baseJoinQuery() {
    return select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.categoryId)),
      innerJoin(wallets, wallets.id.equalsExp(transactions.walletId)),
    ]);
  }

  void _applyDefaultOrdering(JoinedSelectStatement query) {
    query.orderBy([
      OrderingTerm(
        expression: transactions.transactionDate,
        mode: OrderingMode.desc,
      ),
    ]);
  }

  TransactionJoinedModel _mapRowToDetails(TypedResult row) {
    return TransactionJoinedModel(
      transaction: row.readTable(transactions),
      category: row.readTable(categories),
      wallet: row.readTable(wallets),
    );
  }

  List<TransactionJoinedModel> _mapResultsToDetails(List<TypedResult> results) {
    return results.map(_mapRowToDetails).toList();
  }

  // Get all transactions with category and wallet details
  Future<List<TransactionJoinedModel>> getAllTransactions() async {
    final query = _baseJoinQuery();
    _applyDefaultOrdering(query);
    final results = await query.get();
    return _mapResultsToDetails(results);
  }

  // Watch all transactions with category and wallet details
  Stream<List<TransactionJoinedModel>> watchAllTransactions() {
    final query = _baseJoinQuery();
    _applyDefaultOrdering(query);
    return query.watch().map(_mapResultsToDetails);
  }

  // Get transaction by ID with category and wallet details
  Future<TransactionJoinedModel?> getTransactionById(String id) async {
    final query = _baseJoinQuery()..where(transactions.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapRowToDetails(result) : null;
  }

  // Watch transaction by ID with category and wallet details
  Stream<TransactionJoinedModel?> watchTransactionById(String id) {
    final query = _baseJoinQuery()..where(transactions.id.equals(id));
    return query.watchSingleOrNull().map(
      (result) => result != null ? _mapRowToDetails(result) : null,
    );
  }

  // Get transactions by date range with details
  Future<List<TransactionJoinedModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = _baseJoinQuery()
      ..where(
        transactions.transactionDate.isBiggerOrEqualValue(startDate) &
            transactions.transactionDate.isSmallerOrEqualValue(endDate),
      );
    _applyDefaultOrdering(query);
    final results = await query.get();
    return _mapResultsToDetails(results);
  }

  // Watch transactions by date range with details
  Stream<List<TransactionJoinedModel>> watchTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    final query = _baseJoinQuery()
      ..where(
        transactions.transactionDate.isBiggerOrEqualValue(startDate) &
            transactions.transactionDate.isSmallerOrEqualValue(endDate),
      );
    _applyDefaultOrdering(query);
    return query.watch().map(_mapResultsToDetails);
  }

  // Get transactions by wallet ID with details
  Future<List<TransactionJoinedModel>> getTransactionsByWalletId(
    String walletId,
  ) async {
    final query = _baseJoinQuery()
      ..where(transactions.walletId.equals(walletId));
    _applyDefaultOrdering(query);
    final results = await query.get();
    return _mapResultsToDetails(results);
  }

  // Watch transactions by wallet ID with details
  Stream<List<TransactionJoinedModel>> watchTransactionsByWalletId(
    String walletId,
  ) {
    final query = _baseJoinQuery()
      ..where(transactions.walletId.equals(walletId));
    _applyDefaultOrdering(query);
    return query.watch().map(_mapResultsToDetails);
  }

  Future<int> insertTransaction(TransactionsCompanion transaction) async {
    return into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    return update(transactions).replace(transaction);
  }

  Future<int> deleteTransaction(String id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}

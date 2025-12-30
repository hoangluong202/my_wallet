import 'package:drift/drift.dart';
import './../../domain/transaction.dart';
import '../../../../database/app_database.dart';

class TransactionModel {
  static Transaction toEntity(TransactionData data) {
    return Transaction(
      id: data.id,
      categoryId: data.categoryId,
      walletId: data.walletId,
      amount: data.amount,
      note: data.note,
      transactionDate: data.transactionDate,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static TransactionsCompanion toCompanion(Transaction entity) {
    return TransactionsCompanion(
      id: Value(entity.id),
      categoryId: Value(entity.categoryId),
      walletId: Value(entity.walletId),
      amount: Value(entity.amount),
      note: Value(entity.note),
      transactionDate: Value(entity.transactionDate),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<Transaction> toEntityList(List<TransactionData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }

  static List<TransactionsCompanion> toCompanionList(
      List<Transaction> entityList) {
    return entityList.map((entity) => toCompanion(entity)).toList();
  }

  static TransactionsCompanion createNew({
    required String id,
    required String categoryId,
    required String walletId,
    required int amount,
    String? note,
    required DateTime transactionDate,
  }) {
    final now = DateTime.now();
    return TransactionsCompanion.insert(
      id: id,
      categoryId: categoryId,
      walletId: walletId,
      amount: amount,
      note: Value(note),
      transactionDate: transactionDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  static TransactionsCompanion updateCompanion({
    String? categoryId,
    String? walletId,
    int? amount,
    String? note,
    DateTime? transactionDate,
  }) {
    return TransactionsCompanion(
      categoryId:
          categoryId != null ? Value(categoryId) : const Value.absent(),
      walletId: walletId != null ? Value(walletId) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      note: note != null ? Value(note) : const Value.absent(),
      transactionDate: transactionDate != null
          ? Value(transactionDate)
          : const Value.absent(),
    );
  }
}
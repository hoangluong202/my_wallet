import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  TransactionModel({
    required super.id,
    required super.categoryId,
    required super.walletId,
    required super.amount,
    super.note,
    required super.transactionDate,
    required super.createdAt,
    required super.updatedAt,
    super.isSynced = false,
    super.isDeleted = false,
  });

  // Convert from Drift TransactionData to Transaction Entity
  factory TransactionModel.fromDrift(TransactionData data) {
    return TransactionModel(
      id: data.id,
      categoryId: data.categoryId,
      walletId: data.walletId,
      amount: data.amount,
      note: data.note,
      transactionDate: data.transactionDate,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isSynced: data.isSynced,
      isDeleted: data.isDeleted,
    );
  }

  // Convert from Transaction Entity to TransactionModel
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      categoryId: transaction.categoryId,
      walletId: transaction.walletId,
      amount: transaction.amount,
      note: transaction.note,
      transactionDate: transaction.transactionDate,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      isSynced: transaction.isSynced,
      isDeleted: transaction.isDeleted,
    );
  }

  // Convert to Drift TransactionsCompanion for insert/update
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion.insert(
      id: id,
      categoryId: categoryId,
      walletId: walletId,
      amount: amount,
      note: Value(note),
      transactionDate: transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
    );
  }
}

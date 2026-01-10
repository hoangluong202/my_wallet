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
      return await _database.transaction(() async {
        // 1. Insert transaction
        await _database.transactionDao.insertTransaction(
          _payloadToCompanion(transaction),
        );

        // 2. Get category để biết type
        final category = await _database.categoryDao.getCategoryById(
          transaction.categoryId,
        );

        if (category == null) {
          throw Exception('Category not found');
        }

        // 3. Get wallet hiện tại
        final wallet = await _database.walletDao.getWalletById(
          transaction.walletId,
        );

        if (wallet == null) {
          throw Exception('Wallet not found');
        }

        final categoryType = CategoryType.values.firstWhere(
          (e) => e.name == category.type,
          orElse: () => CategoryType.expense,
        );

        int newBalance;
        switch (categoryType) {
          case CategoryType.expense:
          case CategoryType.loan:
            newBalance = wallet.balance - transaction.amount;
            break;
          case CategoryType.income:
          case CategoryType.debt:
            newBalance = wallet.balance + transaction.amount;
            break;
        }

        await _database.walletDao.updateWallet(
          WalletsCompanion(
            id: Value(wallet.id),
            name: Value(wallet.name),
            balance: Value(newBalance),
            iconCode: Value(wallet.iconCode),
            createdAt: Value(wallet.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );

        return transaction.id;
      });
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionPayload transaction) async {
    try {
      print('Updating transaction: ${transaction.id}');
      await _database.transaction(() async {
        final oldTransactionData = await _database.transactionDao
            .getTransactionById(transaction.id);
        print('Old transaction data: $oldTransactionData');
        if (oldTransactionData == null) {
          throw Exception('Transaction not found');
        }

        final oldTransaction = oldTransactionData.transaction;
        final oldCategory = oldTransactionData.category;

        final newCategory = await _database.categoryDao.getCategoryById(
          transaction.categoryId,
        );

        if (newCategory == null) {
          throw Exception('Category not found');
        }

        final oldWallet = await _database.walletDao.getWalletById(
          oldTransaction.walletId,
        );

        if (oldWallet != null) {
          final oldCategoryType = CategoryType.values.firstWhere(
            (e) => e.name == oldCategory.type,
            orElse: () => CategoryType.expense,
          );

          int revertedBalance;
          switch (oldCategoryType) {
            case CategoryType.expense:
            case CategoryType.loan:
              revertedBalance = oldWallet.balance + oldTransaction.amount;
              break;
            case CategoryType.income:
            case CategoryType.debt:
              revertedBalance = oldWallet.balance - oldTransaction.amount;
              break;
          }

          await _database.walletDao.updateWallet(
            WalletsCompanion(
              id: Value(oldWallet.id),
              name: Value(oldWallet.name),
              balance: Value(revertedBalance),
              iconCode: Value(oldWallet.iconCode),
              createdAt: Value(oldWallet.createdAt),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }

        final newWallet = await _database.walletDao.getWalletById(
          transaction.walletId,
        );

        if (newWallet == null) {
          throw Exception('Wallet not found');
        }

        final newCategoryType = CategoryType.values.firstWhere(
          (e) => e.name == newCategory.type,
          orElse: () => CategoryType.expense,
        );

        int newBalance;
        switch (newCategoryType) {
          case CategoryType.expense:
          case CategoryType.loan:
            newBalance = newWallet.balance - transaction.amount;
            break;
          case CategoryType.income:
          case CategoryType.debt:
            newBalance = newWallet.balance + transaction.amount;
            break;
        }

        await _database.walletDao.updateWallet(
          WalletsCompanion(
            id: Value(newWallet.id),
            name: Value(newWallet.name),
            balance: Value(newBalance),
            iconCode: Value(newWallet.iconCode),
            createdAt: Value(newWallet.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await _database.transactionDao.updateTransaction(
          _payloadToCompanion(transaction),
        );
      });
    } catch (e) {
      print('Error: $e');
      throw Exception('Error: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _database.transaction(() async {
        final transactionData = await _database.transactionDao
            .getTransactionById(id);

        if (transactionData == null) {
          throw Exception('Transaction not found');
        }

        final transaction = transactionData.transaction;
        final category = transactionData.category;

        final wallet = await _database.walletDao.getWalletById(
          transaction.walletId,
        );

        if (wallet == null) {
          throw Exception('Wallet not found');
        }

        final categoryType = CategoryType.values.firstWhere(
          (e) => e.name == category.type,
          orElse: () => CategoryType.expense,
        );

        int newBalance;
        switch (categoryType) {
          case CategoryType.expense:
          case CategoryType.loan:
            newBalance = wallet.balance + transaction.amount;
            break;
          case CategoryType.income:
          case CategoryType.debt:
            newBalance = wallet.balance - transaction.amount;
            break;
        }

        await _database.walletDao.updateWallet(
          WalletsCompanion(
            id: Value(wallet.id),
            name: Value(wallet.name),
            balance: Value(newBalance),
            iconCode: Value(wallet.iconCode),
            createdAt: Value(wallet.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await _database.transactionDao.deleteTransaction(id);
      });
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';

abstract class TransactionFirebaseService {
  Future<void> syncTransactionsToCloud(String userId);
  Future<void> syncTransactionsFromCloud(String userId);
  Future<List<TransactionData>> getTransactionsFromCloud(String userId);
  Stream<List<TransactionData>> watchTransactionsFromCloud(String userId);
}

class TransactionFirebaseServiceImpl implements TransactionFirebaseService {
  final FirebaseFirestore _firestore;
  final TransactionDao _transactionDao;
  final firebase_auth.FirebaseAuth _auth;

  TransactionFirebaseServiceImpl(
    this._firestore,
    this._transactionDao,
    this._auth,
  );

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference _getUserTransactionsCollection(String userId) {
    // Verify that the userId matches the authenticated user
    if (_currentUserId != null && _currentUserId != userId) {
      throw Exception(
        'Access denied: userId does not match authenticated user',
      );
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  @override
  Future<void> syncTransactionsToCloud(String userId) async {
    // Step 1: Get dirty transactions (isSynced = false)
    final dirtyTransactions = await _transactionDao.getDirtyTransactions();
    if (dirtyTransactions.isNotEmpty) {
      final batch = _firestore.batch();
      final colRef = _getUserTransactionsCollection(userId);

      for (final transaction in dirtyTransactions) {
        final docRef = colRef.doc(transaction.id);
        batch.set(
          docRef,
          _transactionToMap(transaction),
          SetOptions(merge: true),
        );
      }

      try {
        await batch.commit();

        // Mark all synced transactions
        for (final transaction in dirtyTransactions) {
          await _transactionDao.markAsSynced(transaction.id);
        }
      } catch (e) {
        throw Exception('Failed to sync transactions to cloud: $e');
      }
    }

    // Step 2: Handle deleted transactions (isDeleted = true)
    final deletedTransactions = await _transactionDao.getDeletedTransactions();
    if (deletedTransactions.isNotEmpty) {
      final batch = _firestore.batch();
      final colRef = _getUserTransactionsCollection(userId);

      for (final transaction in deletedTransactions) {
        final docRef = colRef.doc(transaction.id);
        // Soft delete on cloud: mark as deleted
        batch.set(docRef, {
          'id': transaction.id,
          'isDeleted': true,
          'updatedAt': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
      }

      try {
        await batch.commit();
      } catch (e) {
        throw Exception('Failed to sync deleted transactions to cloud: $e');
      }
    }
  }

  @override
  Future<void> syncTransactionsFromCloud(String userId) async {
    final snapshot = await _getUserTransactionsCollection(userId).get();

    if (snapshot.docs.isEmpty) return;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final isDeleted = data['isDeleted'] as bool? ?? false;

      if (isDeleted) {
        // Handle soft-deleted items from cloud
        final existingTransaction = await _transactionDao.getTransactionById(
          data['id'],
        );
        if (existingTransaction != null) {
          await _transactionDao.softDeleteTransaction(data['id']);
        }
      } else {
        // Upsert transaction from cloud
        final transaction = TransactionsCompanion.insert(
          id: data['id'] as String,
          categoryId: data['categoryId'] as String,
          walletId: data['walletId'] as String,
          amount: (data['amount'] as num).toDouble(),
          note: Value(data['note'] as String?),
          transactionDate: DateTime.parse(data['transactionDate'] as String),
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
          isSynced: const Value(true),
          isDeleted: const Value(false),
        );

        // Check if transaction already exists
        final existing = await _transactionDao.getTransactionById(data['id']);
        if (existing != null) {
          // Update existing
          await _transactionDao.updateTransaction(transaction);
        } else {
          // Insert new
          await _transactionDao.insertTransaction(transaction);
        }
      }
    }
  }

  @override
  Future<List<TransactionData>> getTransactionsFromCloud(String userId) async {
    try {
      final snapshot = await _getUserTransactionsCollection(userId).get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionData(
          id: data['id'] as String,
          categoryId: data['categoryId'] as String,
          walletId: data['walletId'] as String,
          amount: (data['amount'] as num).toDouble(),
          note: data['note'] as String?,
          transactionDate: DateTime.parse(data['transactionDate'] as String),
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
          isSynced: data['isSynced'] as bool? ?? true,
          isDeleted: data['isDeleted'] as bool? ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get transactions from cloud: $e');
    }
  }

  @override
  Stream<List<TransactionData>> watchTransactionsFromCloud(String userId) {
    return _getUserTransactionsCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TransactionData(
          id: data['id'] as String,
          categoryId: data['categoryId'] as String,
          walletId: data['walletId'] as String,
          amount: (data['amount'] as num).toDouble(),
          note: data['note'] as String?,
          transactionDate: DateTime.parse(data['transactionDate'] as String),
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
          isSynced: data['isSynced'] as bool? ?? true,
          isDeleted: data['isDeleted'] as bool? ?? false,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _transactionToMap(TransactionData transaction) {
    return {
      'id': transaction.id,
      'categoryId': transaction.categoryId,
      'walletId': transaction.walletId,
      'amount': transaction.amount,
      'note': transaction.note,
      'transactionDate': transaction.transactionDate.toIso8601String(),
      'createdAt': transaction.createdAt.toIso8601String(),
      'updatedAt': transaction.updatedAt.toIso8601String(),
      'isSynced': transaction.isSynced,
      'isDeleted': transaction.isDeleted,
    };
  }
}

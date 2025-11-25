import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:drift/drift.dart';
import '../../../../core/local/database/app_database.dart';
import '../../../../core/local/database/daos/wallet_dao.dart';

abstract class FirebaseService {
  Future<void> syncWalletsToCloud(String userId);
  Future<void> syncWalletsFromCloud(String userId);
  Future<List<WalletData>> getWalletsFromCloud(String userId);
  Stream<List<WalletData>> watchWalletsFromCloud(String userId);
}

class FirebaseServiceImpl implements FirebaseService {
  final FirebaseFirestore _firestore;
  final WalletDao _walletDao;
  final firebase_auth.FirebaseAuth _auth;

  FirebaseServiceImpl(this._firestore, this._walletDao, this._auth);

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference _getUserWalletsCollection(String userId) {
    // Verify that the userId matches the authenticated user
    if (_currentUserId != null && _currentUserId != userId) {
      throw Exception(
        'Access denied: userId does not match authenticated user',
      );
    }
    return _firestore.collection('users').doc(userId).collection('wallets');
  }

  @override
  Future<void> syncWalletsToCloud(String userId) async {
    final wallets = await _walletDao.getAllWallets();
    if (wallets.isEmpty) return;

    final batch = _firestore.batch();
    final colRef = _getUserWalletsCollection(userId);

    for (final wallet in wallets) {
      final docRef = colRef.doc(wallet.id);
      batch.set(docRef, _walletToMap(wallet), SetOptions(merge: true));
    }

    await batch.commit();
  }

  @override
  Future<void> syncWalletsFromCloud(String userId) async {
    final snapshot = await _getUserWalletsCollection(userId).get();

    if (snapshot.docs.isEmpty) return;

    final wallets = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return WalletsCompanion.insert(
        id: data['id'] as String,
        name: data['name'] as String,
        balance: Value((data['balance'] as num).toDouble()),
        currency: Value(data['currency'] as String? ?? 'VND (₫)'),
        iconCode: data['iconCode'] as int,
        iconColor: data['iconColor'] as int,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    }).toList();

    await _walletDao.insertWallets(wallets);
  }

  @override
  Future<List<WalletData>> getWalletsFromCloud(String userId) async {
    try {
      final snapshot = await _getUserWalletsCollection(userId).get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WalletData(
          id: data['id'] as String,
          name: data['name'] as String,
          balance: (data['balance'] as num).toDouble(),
          currency: data['currency'] as String? ?? 'VND (₫)',
          iconCode: data['iconCode'] as int,
          iconColor: data['iconColor'] as int,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get wallets from cloud: $e');
    }
  }

  @override
  Stream<List<WalletData>> watchWalletsFromCloud(String userId) {
    return _getUserWalletsCollection(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return WalletData(
          id: data['id'] as String,
          name: data['name'] as String,
          balance: (data['balance'] as num).toDouble(),
          currency: data['currency'] as String? ?? 'VND (₫)',
          iconCode: data['iconCode'] as int,
          iconColor: data['iconColor'] as int,
          createdAt: DateTime.parse(data['createdAt'] as String),
          updatedAt: DateTime.parse(data['updatedAt'] as String),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> _walletToMap(WalletData wallet) {
    return {
      'id': wallet.id,
      'name': wallet.name,
      'balance': wallet.balance,
      'currency': wallet.currency,
      'iconCode': wallet.iconCode,
      'iconColor': wallet.iconColor,
      'createdAt': wallet.createdAt.toIso8601String(),
      'updatedAt': wallet.updatedAt.toIso8601String(),
    };
  }
}

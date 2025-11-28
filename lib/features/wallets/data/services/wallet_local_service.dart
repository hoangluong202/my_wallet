import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/wallet.dart';
import '../models/wallet_model.dart';

abstract class WalletLocalService {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(String id);
  Future<void> insertWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
  Future<void> softDeleteWallet(String id);
  Future<void> restoreDeletedWallet(String id);
  Future<double> getTotalBalance();
  Future<int> getWalletsCount();
  Future<List<Wallet>> searchWallets(String query);
  Stream<List<Wallet>> watchAllWallets();
  Stream<Wallet?> watchWalletById(String id);
  Future<List<Wallet>> getDirtyWallets();
  Future<List<Wallet>> getDeletedWallets();
  Future<void> markAsSynced(String id);
  Future<void> markAsNotSynced(String id);
}

class WalletLocalServiceImpl implements WalletLocalService {
  final AppDatabase _database;

  WalletLocalServiceImpl(this._database);

  @override
  Future<List<Wallet>> getAllWallets() async {
    final walletDataList = await _database.walletDao.getAllWallets();
    return walletDataList.map((data) => WalletModel.fromDrift(data)).toList();
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    final walletData = await _database.walletDao.getWalletById(id);
    return walletData != null ? WalletModel.fromDrift(walletData) : null;
  }

  @override
  Future<void> insertWallet(Wallet wallet) async {
    final companion = _toInsertCompanion(wallet);
    await _database.walletDao.insertWallet(companion);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final companion = _toCompanion(wallet, isSynced: false);
    await _database.walletDao.updateWallet(companion);
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _database.walletDao.deleteWallet(id);
  }

  @override
  Future<void> softDeleteWallet(String id) async {
    await _database.walletDao.softDeleteWallet(id);
  }

  @override
  Future<void> restoreDeletedWallet(String id) async {
    await _database.walletDao.restoreDeletedWallet(id);
  }

  @override
  Future<double> getTotalBalance() async {
    return await _database.walletDao.getTotalBalance();
  }

  @override
  Future<int> getWalletsCount() async {
    return await _database.walletDao.getWalletsCount();
  }

  @override
  Future<List<Wallet>> searchWallets(String query) async {
    final walletDataList = await _database.walletDao.searchWallets(query);
    return walletDataList.map((data) => WalletModel.fromDrift(data)).toList();
  }

  @override
  Stream<List<Wallet>> watchAllWallets() {
    return _database.walletDao.watchAllWallets().map(
      (list) => list.map((data) => WalletModel.fromDrift(data)).toList(),
    );
  }

  @override
  Stream<Wallet?> watchWalletById(String id) {
    return _database.walletDao
        .watchWalletById(id)
        .map((data) => data != null ? WalletModel.fromDrift(data) : null);
  }

  @override
  Future<List<Wallet>> getDirtyWallets() async {
    final walletDataList = await _database.walletDao.getDirtyWallets();
    return walletDataList.map((data) => WalletModel.fromDrift(data)).toList();
  }

  @override
  Future<List<Wallet>> getDeletedWallets() async {
    final walletDataList = await _database.walletDao.getDeletedWallets();
    return walletDataList.map((data) => WalletModel.fromDrift(data)).toList();
  }

  @override
  Future<void> markAsSynced(String id) async {
    await _database.walletDao.markAsSynced(id);
  }

  @override
  Future<void> markAsNotSynced(String id) async {
    await _database.walletDao.markAsNotSynced(id);
  }

  // Helper methods for Drift Companion conversion
  WalletsCompanion _toCompanion(Wallet wallet, {bool? isSynced}) {
    return WalletsCompanion(
      id: Value(wallet.id),
      name: Value(wallet.name),
      balance: Value(wallet.balance),
      currency: const Value('VND (₫)'),
      iconCode: Value(wallet.icon.codePoint),
      iconColor: Value(wallet.iconColor.value),
      createdAt: Value(wallet.createdOn),
      updatedAt: Value(wallet.lastUpdated),
      isSynced: Value(isSynced ?? wallet.isSynced),
      isDeleted: Value(wallet.isDeleted),
    );
  }

  WalletsCompanion _toInsertCompanion(Wallet wallet) {
    return WalletsCompanion.insert(
      id: wallet.id,
      name: wallet.name,
      balance: Value(wallet.balance),
      currency: const Value('VND (₫)'),
      iconCode: wallet.icon.codePoint,
      iconColor: wallet.iconColor.value,
      createdAt: wallet.createdOn,
      updatedAt: wallet.lastUpdated,
      isSynced: const Value(false),
      isDeleted: const Value(false),
    );
  }
}

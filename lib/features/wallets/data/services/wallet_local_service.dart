import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../database/app_database.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletLocalService {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(String id);
  Future<void> insertWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
  Future<double> getTotalBalance();
  Future<int> getWalletsCount();
  Future<List<Wallet>> searchWallets(String query);
  Stream<List<Wallet>> watchAllWallets();
  Stream<Wallet?> watchWalletById(String id);
}

class WalletLocalServiceImpl implements WalletLocalService {
  final AppDatabase _database;

  WalletLocalServiceImpl(this._database);

  @override
  Future<List<Wallet>> getAllWallets() async {
    final walletDataList = await _database.walletDao.getAllWallets();
    return walletDataList.map(_toEntity).toList();
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    final walletData = await _database.walletDao.getWalletById(id);
    return walletData != null ? _toEntity(walletData) : null;
  }

  @override
  Future<void> insertWallet(Wallet wallet) async {
    final companion = _toCompanion(wallet);
    await _database.walletDao.insertWallet(companion);
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final companion = _toCompanion(wallet);
    await _database.walletDao.updateWallet(companion);
  }

  @override
  Future<void> deleteWallet(String id) async {
    await _database.walletDao.deleteWallet(id);
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
    return walletDataList.map(_toEntity).toList();
  }

  @override
  Stream<List<Wallet>> watchAllWallets() {
    return _database.walletDao.watchAllWallets().map(
      (list) => list.map(_toEntity).toList(),
    );
  }

  @override
  Stream<Wallet?> watchWalletById(String id) {
    return _database.walletDao
        .watchWalletById(id)
        .map((data) => data != null ? _toEntity(data) : null);
  }

  // Helper: Convert WalletData to Wallet Entity
  Wallet _toEntity(WalletData data) {
    return Wallet(
      id: data.id,
      name: data.name,
      balance: data.balance,
      createdOn: data.createdAt,
      lastUpdated: data.updatedAt,
      icon: IconData(data.iconCode, fontFamily: 'MaterialIcons'),
      iconColor: Color(data.iconColor),
    );
  }

  // Helper: Convert Wallet Entity to WalletsCompanion
  WalletsCompanion _toCompanion(Wallet wallet) {
    return WalletsCompanion(
      id: drift.Value(wallet.id),
      name: drift.Value(wallet.name),
      balance: drift.Value(wallet.balance),
      currency: const drift.Value('VND (₫)'),
      iconCode: drift.Value(wallet.icon.codePoint),
      iconColor: drift.Value(wallet.iconColor.value),
      createdAt: drift.Value(wallet.createdOn),
      updatedAt: drift.Value(wallet.lastUpdated),
    );
  }
}

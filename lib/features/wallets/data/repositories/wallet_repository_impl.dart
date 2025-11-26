import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import 'wallet_repository.dart';
import '../services/wallet_local_service.dart';
import '../services/wallet_firebase_service.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalService _localService;
  final WalletFirebaseService _firebaseService;

  WalletRepositoryImpl(this._localService, this._firebaseService);

  @override
  Future<List<Wallet>> getAllWallets() async {
    try {
      return await _localService.getAllWallets();
    } catch (e) {
      throw Exception('Failed to get wallets: $e');
    }
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    try {
      return await _localService.getWalletById(id);
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Future<String> createWallet(Wallet wallet) async {
    try {
      await _localService.insertWallet(wallet);
      return wallet.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _localService.updateWallet(wallet);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    try {
      await _localService.deleteWallet(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getTotalBalance() async {
    try {
      final wallets = await _localService.getAllWallets();
      return wallets.fold<double>(0.0, (sum, w) => sum + w.balance);
    } catch (e) {
      throw Exception('Failed to get total balance: $e');
    }
  }

  @override
  Future<int> getWalletsCount() async {
    try {
      final wallets = await _localService.getAllWallets();
      return wallets.length;
    } catch (e) {
      throw Exception('Failed to get wallets count: $e');
    }
  }

  @override
  Future<List<Wallet>> searchWallets(String query) async {
    try {
      return await _localService.searchWallets(query);
    } catch (e) {
      throw Exception('Failed to search wallets: $e');
    }
  }

  @override
  Future<void> syncToCloud(String userId) async {
    try {
      await _firebaseService.syncWalletsToCloud(userId);
    } catch (e) {
      throw Exception('Failed to sync to cloud: $e');
    }
  }

  @override
  Future<void> pullFromCloud(String userId) async {
    try {
      final cloudWallets = await _firebaseService.getWalletsFromCloud(userId);

      // Convert WalletData to Wallet entities
      final cloudWalletEntities = cloudWallets.map((cloudData) {
        return Wallet(
          id: cloudData.id,
          name: cloudData.name,
          balance: cloudData.balance,
          createdOn: cloudData.createdAt,
          lastUpdated: cloudData.updatedAt,
          icon: _getIconFromCode(cloudData.iconCode),
          iconColor: Color(cloudData.iconColor),
        );
      }).toList();

      // For each cloud wallet, check if it exists locally
      for (final cloudWallet in cloudWalletEntities) {
        final localWallet = await _localService.getWalletById(cloudWallet.id);

        if (localWallet == null) {
          // If not exist locally, insert from cloud
          await _localService.insertWallet(cloudWallet);
        } else {
          // If exists, only update if cloud version is newer
          if (cloudWallet.lastUpdated.isAfter(localWallet.lastUpdated)) {
            await _localService.updateWallet(cloudWallet);
          }
          // If local is newer or same, do nothing (local data takes priority)
        }
      }
    } catch (e) {
      throw Exception('Failed to pull from cloud: $e');
    }
  }

  // Helper method to convert icon code to IconData
  IconData _getIconFromCode(int code) {
    try {
      return IconData(code, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.account_balance_wallet;
    }
  }

  Stream<List<Wallet>> watchAllWallets() {
    return _localService.watchAllWallets();
  }

  Stream<Wallet?> watchWalletById(String id) {
    return _localService.watchWalletById(id);
  }
}

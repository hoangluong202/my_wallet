import '../../../../database/app_database.dart';
import '../../domain/wallet.dart';
import 'wallet_repository.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final AppDatabase _database;

  WalletRepositoryImpl(this._database);

  @override
  Future<List<Wallet>> getAllWallets() async {
    try {
      final walletDataList = await _database.walletDao.getAllWallets();
      return WalletModel.toEntityList(walletDataList);
    } catch (e) {
      throw Exception('Failed to get wallets: $e');
    }
  }

  @override
  Stream<List<Wallet>> watchAllWallets() {
    try {
      return _database.walletDao.watchAllWallets().map(
        WalletModel.toEntityList,
      );
    } catch (e) {
      throw Exception('Failed to watch wallets: $e');
    }
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    try {
      final walletData = await _database.walletDao.getWalletById(id);
      return walletData != null ? WalletModel.toEntity(walletData) : null;
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Stream<Wallet?> watchWalletById(String id) {
    try {
      return _database.walletDao
          .watchWalletById(id)
          .map(
            (walletData) =>
                walletData != null ? WalletModel.toEntity(walletData) : null,
          );
    } catch (e) {
      throw Exception('Failed to watch wallet: $e');
    }
  }

  @override
  Future<String> createWallet(Wallet wallet) async {
    try {
      await _database.walletDao.insertWallet(WalletModel.toCompanion(wallet));
      return wallet.id;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _database.walletDao.updateWallet(WalletModel.toCompanion(wallet));
    } catch (e) {
      throw Exception('Failed to update wallet: $e');
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    try {
      // Use soft delete for sync compatibility
      await _database.walletDao.deleteWallet(id);
    } catch (e) {
      throw Exception('Failed to delete wallet: $e');
    }
  }
}

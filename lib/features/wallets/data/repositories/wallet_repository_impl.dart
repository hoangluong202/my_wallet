import '../../../../database/app_database.dart';
import './../domains/wallet_entity.dart';
import 'wallet_repository.dart';
import '../models/wallet_model.dart';

class WalletRepositoryImpl implements WalletRepository {
  final AppDatabase _database;

  WalletRepositoryImpl(this._database);

  @override
  Future<List<WalletEntity>> getAllWallets() async {
    try {
      final walletDataList = await _database.walletDao.getAllWallets();
      return WalletModel.toEntityList(walletDataList);
    } catch (e) {
      throw Exception('Failed to get wallets: $e');
    }
  }

  @override
  Future<WalletEntity?> getWalletById(String id) async {
    try {
      final walletData = await _database.walletDao.getWalletById(id);
      return walletData != null ? WalletModel.toEntity(walletData) : null;
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Future<String> createWallet(WalletEntity wallet) async {
    try {
      await _database.walletDao.insertWallet(WalletModel.toCompanion(wallet));
      return wallet.id;
    } catch (e) {
      throw Exception('Failed to create wallet: $e');
    }
  }

  @override
  Future<void> updateWallet(WalletEntity wallet) async {
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

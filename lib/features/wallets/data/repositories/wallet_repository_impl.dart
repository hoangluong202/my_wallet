import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletLocalDataSource _localDataSource;

  WalletRepositoryImpl(this._localDataSource);

  @override
  Future<List<Wallet>> getAllWallets() async {
    try {
      return await _localDataSource.getAllWallets();
    } catch (e) {
      throw Exception('Failed to get wallets: $e');
    }
  }

  @override
  Future<Wallet?> getWalletById(String id) async {
    try {
      return await _localDataSource.getWalletById(id);
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  @override
  Future<String> createWallet(Wallet wallet) async {
    try {
      await _localDataSource.insertWallet(wallet);
      return wallet.id;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _localDataSource.updateWallet(wallet);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteWallet(String id) async {
    try {
      await _localDataSource.deleteWallet(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getTotalBalance() async {
    try {
      final wallets = await _localDataSource.getAllWallets();
      return wallets.fold<double>(0.0, (sum, w) => sum + w.balance);
    } catch (e) {
      throw Exception('Failed to get total balance: $e');
    }
  }

  @override
  Future<int> getWalletsCount() async {
    try {
      final wallets = await _localDataSource.getAllWallets();
      return wallets.length;
    } catch (e) {
      throw Exception('Failed to get wallets count: $e');
    }
  }

  @override
  Future<List<Wallet>> searchWallets(String query) async {
    try {
      return await _localDataSource.searchWallets(query);
    } catch (e) {
      throw Exception('Failed to search wallets: $e');
    }
  }

  @override
  Stream<List<Wallet>> watchAllWallets() {
    return _localDataSource.watchAllWallets();
  }

  @override
  Stream<Wallet?> watchWalletById(String id) {
    return _localDataSource.watchWalletById(id);
  }
}

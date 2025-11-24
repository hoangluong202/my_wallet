import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAllWallets();
  Future<Wallet?> getWalletById(String id);
  Future<String> createWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
  Future<double> getTotalBalance();
  Future<int> getWalletsCount();
  Future<List<Wallet>> searchWallets(String query);

  // Cloud sync methods
  Future<void> syncToCloud(String userId);
  Future<void> pullFromCloud(String userId);
}

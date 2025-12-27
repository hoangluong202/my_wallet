import './../domains/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getAllWallets();
  Future<WalletEntity?> getWalletById(String id);
  Future<String> createWallet(WalletEntity wallet);
  Future<void> updateWallet(WalletEntity wallet);
  Future<void> deleteWallet(String id);
}

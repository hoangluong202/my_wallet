import '../../domain/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAllWallets();
  Stream<List<Wallet>> watchAllWallets();
  Future<Wallet?> getWalletById(String id);
  Stream<Wallet?> watchWalletById(String id);
  Future<String> createWallet(Wallet wallet);
  Future<void> updateWallet(Wallet wallet);
  Future<void> deleteWallet(String id);
  Future<void> transferMoney({
    required String sourceWalletId,
    required String targetWalletId,
    required int amount,
  });
}

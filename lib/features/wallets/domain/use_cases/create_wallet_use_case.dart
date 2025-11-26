import '../entities/wallet.dart';
import '../../data/repositories/wallet_repository.dart';

class CreateWalletUseCase {
  final WalletRepository repository;

  CreateWalletUseCase(this.repository);

  Future<String> call(Wallet wallet) async {
    return await repository.createWallet(wallet);
  }
}

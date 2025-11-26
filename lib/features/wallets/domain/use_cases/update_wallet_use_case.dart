import '../entities/wallet.dart';
import '../../data/repositories/wallet_repository.dart';

class UpdateWalletUseCase {
  final WalletRepository repository;

  UpdateWalletUseCase(this.repository);

  Future<void> call(Wallet wallet) async {
    return await repository.updateWallet(wallet);
  }
}

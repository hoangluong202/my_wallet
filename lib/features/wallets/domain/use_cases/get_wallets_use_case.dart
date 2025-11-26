import '../entities/wallet.dart';
import '../../data/repositories/wallet_repository.dart';

class GetWalletsUseCase {
  final WalletRepository repository;

  GetWalletsUseCase(this.repository);

  Future<List<Wallet>> call() async {
    return await repository.getAllWallets();
  }
}

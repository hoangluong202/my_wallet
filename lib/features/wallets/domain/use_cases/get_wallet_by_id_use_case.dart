import '../entities/wallet.dart';
import '../../data/repositories/wallet_repository.dart';

class GetWalletByIdUseCase {
  final WalletRepository repository;

  GetWalletByIdUseCase(this.repository);

  Future<Wallet?> call(String id) async {
    return await repository.getWalletById(id);
  }
}

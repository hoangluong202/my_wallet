import '../../data/repositories/wallet_repository.dart';

class DeleteWalletUseCase {
  final WalletRepository repository;

  DeleteWalletUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteWallet(id);
  }
}

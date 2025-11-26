import '../../data/repositories/wallet_repository.dart';

class GetTotalBalanceUseCase {
  final WalletRepository repository;

  GetTotalBalanceUseCase(this.repository);

  Future<double> call() async {
    return await repository.getTotalBalance();
  }
}

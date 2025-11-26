import '../../data/repositories/wallet_repository.dart';

class SyncWalletsUseCase {
  final WalletRepository repository;

  SyncWalletsUseCase(this.repository);

  Future<void> syncToCloud(String userId) async {
    await repository.syncToCloud(userId);
  }

  Future<void> pullFromCloud(String userId) async {
    await repository.pullFromCloud(userId);
  }
}

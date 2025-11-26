import '../../data/repositories/categories_repository.dart';

class SyncCategoriesUseCase {
  final CategoriesRepository repository;

  SyncCategoriesUseCase(this.repository);

  Future<void> syncToCloud(String userId) async {
    await repository.syncToCloud(userId);
  }

  Future<void> pullFromCloud(String userId) async {
    await repository.pullFromCloud(userId);
  }
}

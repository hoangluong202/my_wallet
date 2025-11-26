import '../../data/repositories/categories_repository.dart';

class DeleteCategoryUseCase {
  final CategoriesRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCategory(id);
  }
}

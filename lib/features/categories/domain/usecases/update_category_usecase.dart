import '../entities/category.dart';
import '../../data/repositories/categories_repository.dart';

class UpdateCategoryUseCase {
  final CategoriesRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.updateCategory(category);
  }
}

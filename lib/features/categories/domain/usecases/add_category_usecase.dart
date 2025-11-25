import '../entities/category.dart';
import '../repositories/categories_repository.dart';

class AddCategoryUseCase {
  final CategoriesRepository repository;

  AddCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.addCategory(category);
  }
}

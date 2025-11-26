import '../entities/category.dart';
import '../../data/repositories/categories_repository.dart';

class GetCategoryByIdUseCase {
  final CategoriesRepository repository;

  GetCategoryByIdUseCase(this.repository);

  Future<Category> call(String id) async {
    return await repository.getCategoryById(id);
  }
}

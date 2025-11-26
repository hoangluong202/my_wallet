import '../entities/category.dart';
import '../../data/repositories/categories_repository.dart';

class GetCategoriesByTypeUseCase {
  final CategoriesRepository repository;

  GetCategoriesByTypeUseCase(this.repository);

  Future<List<Category>> call(CategoryType type) async {
    return await repository.getCategoriesByType(type);
  }
}

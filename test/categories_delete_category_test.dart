import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/categories/data/repositories/categories_repository.dart';
import 'package:my_wallet/features/categories/domain/category.dart';
import 'package:my_wallet/features/categories/presentation/list/categories_viewmodel.dart';

class FakeCategoriesRepository implements CategoriesRepository {
  String? deletedId;
  String? transferToCategoryId;

  @override
  Future<void> addCategory(Category category) async {}

  @override
  Future<void> updateCategory(Category category) async {}

  @override
  Future<void> deleteCategory(String id, {String? transferToCategoryId}) async {
    deletedId = id;
    this.transferToCategoryId = transferToCategoryId;
  }

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Stream<List<Category>> watchCategories() => Stream.value([]);

  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async => [];

  @override
  Stream<List<Category>> watchCategoriesByType(CategoryType type) =>
      Stream.value([]);

  @override
  Future<Category?> getCategoryById(String id) async => null;

  @override
  Stream<Category?> watchCategoryById(String id) => Stream.value(null);

  @override
  Future<bool> hasChildCategory(String parentCategoryId) async => false;

  @override
  Future<Category?> getParentCategory(String childCategoryId) async => null;

  @override
  Future<void> addCategoryWithValidation(Category category) async {}

  @override
  Future<void> updateCategoryWithValidation(Category category) async {}
}

void main() {
  test('deleteCategory forwards transfer target to repository', () async {
    final repository = FakeCategoriesRepository();
    final viewModel = CategoriesViewModel(repository);

    await viewModel.deleteCategory(
      'category-1',
      transferToCategoryId: 'category-2',
    );

    expect(repository.deletedId, 'category-1');
    expect(repository.transferToCategoryId, 'category-2');
  });
}

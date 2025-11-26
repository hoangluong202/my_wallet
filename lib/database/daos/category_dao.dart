import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // Get all categories
  Future<List<CategoryData>> getAllCategories() async {
    return (select(categories)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  // Get categories by type
  Future<List<CategoryData>> getCategoriesByType(String type) async {
    return (select(categories)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // Get category by ID
  Future<CategoryData?> getCategoryById(String id) async {
    return (select(
      categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Insert category
  Future<int> insertCategory(CategoriesCompanion category) async {
    return into(categories).insert(category);
  }

  // Update category
  Future<bool> updateCategory(CategoriesCompanion category) async {
    return update(categories).replace(category);
  }

  // Delete category
  Future<int> deleteCategory(String id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  // Get categories count
  Future<int> getCategoriesCount() async {
    final query = selectOnly(categories)..addColumns([categories.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(categories.id.count()) ?? 0;
  }

  // Get categories count by type
  Future<int> getCategoriesCountByType(String type) async {
    final query = selectOnly(categories)
      ..where(categories.type.equals(type))
      ..addColumns([categories.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(categories.id.count()) ?? 0;
  }

  // Watch all categories (stream)
  Stream<List<CategoryData>> watchAllCategories() {
    return (select(categories)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  // Watch categories by type (stream)
  Stream<List<CategoryData>> watchCategoriesByType(String type) {
    return (select(categories)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // Search categories by name
  Future<List<CategoryData>> searchCategories(String query) async {
    return (select(categories)
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // Clear all categories
  Future<int> deleteAllCategories() async {
    return delete(categories).go();
  }
}

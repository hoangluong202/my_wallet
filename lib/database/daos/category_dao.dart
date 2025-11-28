import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  // Get all categories (excluding soft-deleted)
  Future<List<CategoryData>> getAllCategories() async {
    return (select(categories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Get categories by type (excluding soft-deleted)
  Future<List<CategoryData>> getCategoriesByType(String type) async {
    return (select(categories)
          ..where((t) => t.type.equals(type) & t.isDeleted.equals(false))
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

  // Get categories count (excluding soft-deleted)
  Future<int> getCategoriesCount() async {
    final query = selectOnly(categories)
      ..where(categories.isDeleted.equals(false))
      ..addColumns([categories.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(categories.id.count()) ?? 0;
  }

  // Get categories count by type (excluding soft-deleted)
  Future<int> getCategoriesCountByType(String type) async {
    final query = selectOnly(categories)
      ..where(categories.type.equals(type) & categories.isDeleted.equals(false))
      ..addColumns([categories.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(categories.id.count()) ?? 0;
  }

  // Watch all categories (stream, excluding soft-deleted)
  Stream<List<CategoryData>> watchAllCategories() {
    return (select(categories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  // Watch categories by type (stream, excluding soft-deleted)
  Stream<List<CategoryData>> watchCategoriesByType(String type) {
    return (select(categories)
          ..where((t) => t.type.equals(type) & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // Search categories by name (excluding soft-deleted)
  Future<List<CategoryData>> searchCategories(String query) async {
    return (select(categories)
          ..where((t) => t.name.like('%$query%') & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // Get dirty categories (isSynced = false and isDeleted = false)
  Future<List<CategoryData>> getDirtyCategories() async {
    return (select(categories)
          ..where((t) => t.isSynced.equals(false) & t.isDeleted.equals(false)))
        .get();
  }

  // Get deleted categories (isDeleted = true)
  Future<List<CategoryData>> getDeletedCategories() async {
    return (select(categories)..where((t) => t.isDeleted.equals(true))).get();
  }

  // Mark category as synced
  Future<int> markAsSynced(String id) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      const CategoriesCompanion(isSynced: Value(true)),
    );
  }

  // Soft delete category (mark as deleted but keep in DB)
  Future<int> softDeleteCategory(String id) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Restore deleted category
  Future<int> restoreDeletedCategory(String id) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        isDeleted: const Value(false),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Clear all categories
  Future<int> deleteAllCategories() async {
    return delete(categories).go();
  }
}

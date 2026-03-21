import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<CategoryData>> getAllCategories() async {
    return (select(categories)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Stream<List<CategoryData>> watchAllCategories() {
    return (select(categories)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<List<CategoryData>> getCategoriesByType(String type) async {
    return (select(categories)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  Stream<List<CategoryData>> watchCategoriesByType(String type) {
    return (select(categories)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<CategoryData?> getCategoryById(String id) async {
    return (select(
      categories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<CategoryData?> watchCategoryById(String id) {
    return (select(
      categories,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> insertCategory(CategoriesCompanion category) async {
    return into(categories).insert(category);
  }

  Future<bool> updateCategory(CategoriesCompanion category) async {
    return update(categories).replace(category);
  }

  Future<int> deleteCategory(String id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllCategories() async {
    return delete(categories).go();
  }

  // NEW: Get child category for a parent
  Future<CategoryData?> getChildCategory(String parentCategoryId) async {
    return (select(categories)
          ..where((t) => t.parentCategoryId.equals(parentCategoryId)))
        .getSingleOrNull();
  }

  // NEW: Get all child categories for a parent
  Future<List<CategoryData>> getChildCategories(String parentCategoryId) async {
    return (select(categories)
          ..where((t) => t.parentCategoryId.equals(parentCategoryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // NEW: Watch all child categories for a parent
  Stream<List<CategoryData>> watchChildCategories(String parentCategoryId) {
    return (select(categories)
          ..where((t) => t.parentCategoryId.equals(parentCategoryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  // NEW: Check if category has a child
  Future<bool> hasChild(String categoryId) async {
    final child = await getChildCategory(categoryId);
    return child != null;
  }

  // NEW: Get parent category
  Future<CategoryData?> getParentCategory(String childCategoryId) async {
    final child = await getCategoryById(childCategoryId);
    if (child == null || child.parentCategoryId == null) return null;
    return getCategoryById(child.parentCategoryId!);
  }

  // NEW: Get all root categories (parent_category_id is null)
  Future<List<CategoryData>> getRootCategories() async {
    return (select(categories)
          ..where((t) => t.parentCategoryId.isNull())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // NEW: Watch all root categories
  Stream<List<CategoryData>> watchRootCategories() {
    return (select(categories)
          ..where((t) => t.parentCategoryId.isNull())
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}

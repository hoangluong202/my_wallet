import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/category.dart';

class CategoryModel {
  static CategoryType _getCategoryType(String type) {
    return CategoryType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
    );
  }

  static Category toEntity(CategoryData data) {
    return Category(
      id: data.id,
      name: data.name,
      type: _getCategoryType(data.type),
      iconCode: data.iconCode,
      description: data.description,
      parentCategoryId: data.parentCategoryId,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static CategoriesCompanion toCompanion(Category entity) {
    return CategoriesCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.toString().split('.').last),
      iconCode: Value(entity.iconCode),
      description: Value(entity.description),
      parentCategoryId: Value(entity.parentCategoryId),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<Category> toEntityList(List<CategoryData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }

  static List<CategoriesCompanion> toCompanionList(List<Category> entityList) {
    return entityList.map((entity) => toCompanion(entity)).toList();
  }

  static CategoriesCompanion createNew({
    required String id,
    required String name,
    required String type,
    required int iconCode,
    String? description,
    String? parentCategoryId,
  }) {
    final now = DateTime.now();
    return CategoriesCompanion.insert(
      id: id,
      name: name,
      type: type,
      iconCode: iconCode,
      description: Value(description),
      parentCategoryId: parentCategoryId != null
          ? Value(parentCategoryId)
          : const Value.absent(),
      createdAt: now,
      updatedAt: now,
    );
  }

  static CategoriesCompanion updateCompanion({
    String? name,
    String? type,
    int? iconCode,
    String? description,
    String? parentCategoryId,
  }) {
    return CategoriesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      iconCode: iconCode != null ? Value(iconCode) : const Value.absent(),
      description: description != null
          ? Value(description)
          : const Value.absent(),
      parentCategoryId: parentCategoryId != null
          ? Value(parentCategoryId)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }
}

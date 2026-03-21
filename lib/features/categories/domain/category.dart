enum CategoryType { income, expense, debt, loan }

class Category {
  final String id;
  final String name;
  final CategoryType type;
  final int iconCode;
  final String? description;
  final String? parentCategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    this.description,
    this.parentCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter to check if this is a parent category
  bool get isParentCategory => parentCategoryId == null;

  // Getter to check if this is a child category
  bool get isChildCategory => parentCategoryId != null;
}

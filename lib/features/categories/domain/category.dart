enum CategoryType { income, expense, debt, loan }

class Category {
  final String id;
  final String name;
  final CategoryType type;
  final int iconCode;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}

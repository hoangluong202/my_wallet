import '../../categories/domain/category.dart';

class Budget {
  final String id;
  final String categoryId;
  final int estimatedAmount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Resolved category (joined from categories table)
  final Category? category;

  Budget({
    required this.id,
    required this.categoryId,
    required this.estimatedAmount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.category,
  });
}

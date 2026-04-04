class BudgetPayload {
  final String id;
  final String categoryId;
  final int estimatedAmount;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetPayload({
    required this.id,
    required this.categoryId,
    required this.estimatedAmount,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });
}

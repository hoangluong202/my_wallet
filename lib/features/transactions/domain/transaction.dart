class Transaction {
  final String id;
  final String categoryId;
  final String walletId;
  final int amount;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.walletId,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

}

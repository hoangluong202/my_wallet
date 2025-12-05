class Transaction {
  final String id;
  final String categoryId;
  final String walletId;
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted;

  Transaction({
    required this.id,
    required this.categoryId,
    required this.walletId,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  Transaction copyWith({
    String? id,
    String? categoryId,
    String? walletId,
    double? amount,
    String? note,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Transaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Transaction{id: $id, categoryId: $categoryId, walletId: $walletId, amount: $amount, transactionDate: $transactionDate}';
  }
}

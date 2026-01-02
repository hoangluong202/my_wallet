import '../../wallets/domain/wallet.dart';
import '../../categories/domain/category.dart';

class Transaction {
  final String id;
  final int amount;
  final String? note;
  final DateTime transactionDate;
  final Wallet wallet;
  final Category category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.wallet,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });
}

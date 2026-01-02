import '../../../wallets/presentation/model/wallet_view_data.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../domain/transaction.dart';

class TransactionViewData {
  final String id;
  final String? note;
  final DateTime transactionDate;
  final int amount;
  final WalletViewData wallet;
  final CategoryViewData category;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionViewData({
    required this.id,
    required this.note,
    required this.transactionDate,
    required this.amount,
    required this.wallet,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionViewData.fromDomain(Transaction transaction) {
    return TransactionViewData(
      id: transaction.id,
      note: transaction.note,
      transactionDate: transaction.transactionDate,
      amount: transaction.amount,
      wallet: WalletViewData.fromDomain(transaction.wallet),
      category: CategoryViewData.fromDomain(transaction.category),
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }
}

import '../model/transaction_view_data.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionViewmodel {
  final TransactionRepository _transactionRepository;

  TransactionViewmodel(this._transactionRepository);

  Stream<List<TransactionViewData>> watchAllTransactions() {
    return _transactionRepository.watchAllTransactions().map(
      (transactions) => transactions
          .map((transaction) => TransactionViewData.fromDomain(transaction))
          .toList(),
    );
  }

  Stream<TransactionViewData> watchTransactionById(String transactionId) {
    return _transactionRepository
        .watchTransactionById(transactionId)
        .map((transaction) => TransactionViewData.fromDomain(transaction!));
  }

  Future<void> deleteTransaction(String transactionId) async {
    return await _transactionRepository.deleteTransaction(transactionId);
  }
}

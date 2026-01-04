import '../model/transaction_view_data.dart';
import '../../data/repositories/transaction_repository.dart';
import '../form/transaction_payload.dart';

class TransactionViewModel {
  final TransactionRepository _transactionRepository;

  TransactionViewModel(this._transactionRepository);

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

  Future<String> addTransaction(TransactionPayload transaction) async {
    return await _transactionRepository.createTransaction(transaction);
  }

  Future<void> updateTransaction(TransactionPayload transaction) async {
    return await _transactionRepository.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    return await _transactionRepository.deleteTransaction(transactionId);
  }
}

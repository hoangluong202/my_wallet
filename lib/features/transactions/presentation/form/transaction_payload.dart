import 'package:uuid/uuid.dart';
import '../form/transaction_form_state.dart';

class TransactionPayload {
  final String id;
  final String categoryId;
  final String walletId;
  final int amount;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionPayload({
    required this.id,
    required this.categoryId,
    required this.walletId,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionPayload.fromFormState(TransactionFormState formState) {
    if (formState.selectedCategoryId == null) {
      throw Exception('Category is required');
    }
    if (formState.selectedWalletId == null) {
      throw Exception('Wallet is required');
    }
    if (formState.parseAmount() <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    final now = DateTime.now();
    return TransactionPayload(
      id: const Uuid().v4(),
      categoryId: formState.selectedCategoryId!,
      walletId: formState.selectedWalletId!,
      amount: formState.parseAmount(),
      note: formState.note.isEmpty ? null : formState.note,
      transactionDate: formState.selectedDate,
      createdAt: now,
      updatedAt: now,
    );
  }
}

import '../../../categories/domain/category.dart';

class TransactionFormState {
  final CategoryType selectedType;
  final String? selectedCategoryId;
  final String? selectedWalletId;
  final DateTime selectedDate;
  final String amount;
  final String note;

  const TransactionFormState({
    required this.selectedType,
    this.selectedCategoryId,
    this.selectedWalletId,
    required this.selectedDate,
    this.amount = '',
    this.note = '',
  });

  TransactionFormState copyWith({
    CategoryType? selectedType,
    String? selectedCategoryId,
    String? selectedWalletId,
    DateTime? selectedDate,
    String? amount,
    String? note,
  }) {
    return TransactionFormState(
      selectedType: selectedType ?? this.selectedType,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
      selectedDate: selectedDate ?? this.selectedDate,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  // Factory constructor for initial state
  factory TransactionFormState.initial() {
    return TransactionFormState(
      selectedType: CategoryType.expense,
      selectedDate: DateTime.now(),
    );
  }

  // Validation
  bool get isValid {
    return selectedCategoryId != null &&
        selectedWalletId != null &&
        amount.isNotEmpty &&
        parseAmount() > 0;
  }

  int parseAmount() {
    final cleanText = amount.replaceAll('.', '');
    return int.tryParse(cleanText) ?? 0;
  }
}

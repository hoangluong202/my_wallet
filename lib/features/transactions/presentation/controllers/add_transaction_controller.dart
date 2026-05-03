import 'package:flutter/material.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../categories/domain/category.dart';
import '../form/transaction_form_state.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import '../form/transaction_payload.dart';

class AddTransactionController {
  final TransactionsViewModel _transactionViewModel;
  final CategoriesViewModel _categoriesViewModel;
  final WalletsViewModel _walletsViewModel;

  TransactionFormState _formState;
  List<CategoryViewData> _allCategories = [];
  List<WalletViewData> _allWallets = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  AddTransactionController({
    required TransactionsViewModel transactionViewModel,
    required CategoriesViewModel categoriesViewModel,
    required WalletsViewModel walletsViewModel,
  }) : _transactionViewModel = transactionViewModel,
       _categoriesViewModel = categoriesViewModel,
       _walletsViewModel = walletsViewModel,
       _formState = TransactionFormState.initial();

  // Getters
  TransactionFormState get formState => _formState;
  List<CategoryViewData> get allCategories => _allCategories;
  List<WalletViewData> get allWallets => _allWallets;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;

  List<CategoryViewData> get filteredCategories {
    return _allCategories
        .where((cat) => cat.type == _formState.selectedType)
        .toList();
  }

  WalletViewData? get selectedWallet {
    return _allWallets
        .where((w) => w.id == _formState.selectedWalletId)
        .firstOrNull;
  }

  // Initialize data
  Future<void> loadInitialData() async {
    _isLoading = true;

    try {
      // Load data in parallel for better performance
      final results = await Future.wait([
        _categoriesViewModel.categoriesStream.first,
        _walletsViewModel.walletsStream.first,
      ]);

      _allCategories = (results[0] as List<CategoryViewData>)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _allWallets = (results[1] as List<WalletViewData>)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Set default selections if data exists
      if (_allCategories.isNotEmpty && _allWallets.isNotEmpty) {
        final firstCategory = _allCategories
            .where((c) => c.type == _formState.selectedType)
            .firstOrNull;

        _formState = _formState.copyWith(
          selectedCategoryId: firstCategory?.id,
          selectedWalletId: _allWallets.first.id,
        );
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  // Update form state
  void updateFormState(TransactionFormState newState) {
    _formState = newState;
  }

  void updateAmount(String amount) {
    _formState = _formState.copyWith(amount: amount);
  }

  void updateNote(String note) {
    _formState = _formState.copyWith(note: note);
  }

  void updateSelectedCategory(String categoryId) {
    _formState = _formState.copyWith(selectedCategoryId: categoryId);
  }

  void updateSelectedWallet(String walletId) {
    _formState = _formState.copyWith(selectedWalletId: walletId);
  }

  void updateSelectedDate(DateTime date) {
    _formState = _formState.copyWith(selectedDate: date);
  }

  void updateTransactionType(CategoryType type) {
    final firstCategory = _allCategories
        .where((c) => c.type == type)
        .firstOrNull;
    _formState = _formState.copyWith(
      selectedType: type,
      selectedCategoryId: firstCategory?.id,
    );
  }

  // Validation
  bool validateForm() {
    return _formState.isValid;
  }

  // Submit transaction
  Future<void> submitTransaction() async {
    if (!_formState.isValid) {
      throw Exception('Form is not valid');
    }

    _isSubmitting = true;

    try {
      final transaction = TransactionPayload.fromFormState(_formState);
      await _transactionViewModel.addTransaction(transaction);
    } catch (e) {
      debugPrint('Error submitting transaction: $e');
      rethrow;
    } finally {
      _isSubmitting = false;
    }
  }

  // Dispose
  void dispose() {
    // Clean up if needed
  }
}

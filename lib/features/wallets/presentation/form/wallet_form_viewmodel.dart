import 'package:flutter/material.dart';
import '../../../../core/constants/wallet_constants.dart';
import '../model/wallet_view_data.dart';
import '../../domain/wallet.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletFormViewModel extends ChangeNotifier {
  final WalletRepository _repository;

  final TextEditingController nameController;
  final TextEditingController balanceController;
  final bool isEditMode;
  final WalletViewData? existingWallet;

  String _selectedCurrency = WalletConstants.defaultCurrency;
  IconData _selectedIcon = Icons.account_balance_wallet;
  Color _selectedIconColor = Colors.blue;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WalletFormViewModel({
    required WalletRepository repository,
    this.isEditMode = false,
    this.existingWallet,
  }) : _repository = repository,
       nameController = TextEditingController(text: existingWallet?.name ?? ''),
       balanceController = TextEditingController(
         text: existingWallet != null ? _formatVND(existingWallet.balance) : '',
       ) {
    if (existingWallet != null) {
      _selectedIcon = existingWallet!.icon;
      _selectedIconColor = existingWallet!.color;
    }
  }

  String get selectedCurrency => _selectedCurrency;
  IconData get selectedIcon => _selectedIcon;
  Color get selectedIconColor => _selectedIconColor;

  void selectIcon(IconData icon, Color color) {
    _selectedIcon = icon;
    _selectedIconColor = color;
    notifyListeners();
  }

  void selectCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a wallet name';
    }
    if (value.length < 2) {
      return 'Wallet name must be at least 2 characters';
    }
    return null;
  }

  String? validateBalance(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ${isEditMode ? 'a' : 'an initial'} balance';
    }
    final cleanValue = int.tryParse(value.replaceAll('.', ''));
    if (cleanValue == null) {
      return 'Please enter a valid number';
    }
    if (cleanValue < 0) {
      return 'Balance cannot be negative';
    }
    return null;
  }

  void formatBalance(String value) {
    if (value.isNotEmpty) {
      final cleanValue = int.tryParse(value.replaceAll('.', '')) ?? 0;
      final formatted = _formatVND(cleanValue);
      balanceController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<bool> createWallet() async {
    _setLoading(true);
    _clearError();

    try {
      final wallet = Wallet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        balance: _parseBalance(),
        iconCode: _selectedIcon.codePoint,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.createWallet(wallet);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to create wallet: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateWallet() async {
    if (existingWallet == null) {
      _setError('No wallet to update');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final wallet = Wallet(
        id: existingWallet!.id,
        name: nameController.text.trim(),
        balance: _parseBalance(),
        iconCode: _selectedIcon.codePoint,
        createdAt: existingWallet!.createdAt,
        updatedAt: DateTime.now(),
      );

      await _repository.updateWallet(wallet);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update wallet: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteWallet() async {
    if (existingWallet == null) {
      _setError('No wallet to delete');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteWallet(existingWallet!.id); // ✅ Call repository
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to delete wallet: $e');
      _setLoading(false);
      return false;
    }
  }

  int _parseBalance() {
    final cleanValue = balanceController.text.replaceAll('.', '');
    return int.parse(cleanValue);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  static String _formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }
}

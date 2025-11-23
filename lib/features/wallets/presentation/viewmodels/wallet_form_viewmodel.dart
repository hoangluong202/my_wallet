import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/models/wallet_icon_data.dart';
import '../../../../core/constants/wallet_constants.dart';

class WalletFormViewModel extends ChangeNotifier {
  final TextEditingController nameController;
  final TextEditingController balanceController;

  String _selectedCurrency = WalletConstants.defaultCurrency;
  IconData _selectedIcon = Icons.account_balance_wallet;
  Color _selectedIconColor = Colors.blue;

  final bool isEditMode;
  final Wallet? existingWallet;

  WalletFormViewModel({this.isEditMode = false, this.existingWallet})
    : nameController = TextEditingController(text: existingWallet?.name ?? ''),
      balanceController = TextEditingController(
        text: existingWallet != null
            ? _formatVND(existingWallet.balance.toInt())
            : '',
      ) {
    if (existingWallet != null) {
      _selectedIcon = existingWallet?.icon ?? Icons.account_balance_wallet;
      _selectedIconColor = existingWallet?.iconColor ?? Colors.blue; 
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

  Map<String, dynamic> getWalletData() {
    return {
      'id':
          existingWallet?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      'name': nameController.text.trim(),
      'currency': _selectedCurrency,
      'balance': int.parse(
        balanceController.text.replaceAll('.', ''),
      ).toDouble(),
      'icon': _selectedIcon,
      'iconColor': _selectedIconColor,
      'createdOn': existingWallet?.createdOn ?? DateTime.now(),
      'lastUpdated': DateTime.now(),
    };
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

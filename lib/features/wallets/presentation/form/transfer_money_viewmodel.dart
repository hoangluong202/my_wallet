import 'package:flutter/material.dart';
import 'package:my_wallet/features/wallets/data/repositories/wallet_repository.dart';
import '../../domain/wallet.dart';
import '../../../../core/utils/currency_formatter.dart';

class TransferMoneyViewModel extends ChangeNotifier {
  final WalletRepository _walletRepo;

  TransferMoneyViewModel({required WalletRepository walletRepo})
    : _walletRepo = walletRepo;

  final TextEditingController amountController = TextEditingController();

  List<Wallet> _availableWallets = [];
  Wallet? _targetWallet;

  String? _errorTo;
  String? _errorAmount;
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _successMessage;

  String? get errorTo => _errorTo;
  String? get errorAmount => _errorAmount;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get successMessage => _successMessage;

  List<Wallet> get availableWallets => _availableWallets;

  Future<void> loadAvailableWallets(String sourceWalletId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _availableWallets = await _walletRepo.getAllWallets();
      _availableWallets.removeWhere((wallet) => wallet.id == sourceWalletId);

      if (_availableWallets.isNotEmpty) {
        _targetWallet = _availableWallets.first;
      }
      notifyListeners();
    } catch (e) {
      _errorTo = 'Failed to load wallets: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> validateTo() async {
    final value = _targetWallet?.id ?? '';
    if (value.isEmpty) {
      _errorTo = 'Please select a target wallet';
    } else {
      _errorTo = null;
    }
    notifyListeners();
  }

  void validateAmount(String value) {
    final amount = CurrencyFormatter.parseVND(value);
    if (value.isEmpty) {
      _errorAmount = 'Please enter an amount';
    } else {
      if (amount <= 0) {
        _errorAmount = 'Please enter a valid positive amount';
      } else {
        _errorAmount = null;
      }
    }
    notifyListeners();
  }

  bool get isFormValid =>
      _errorTo == null &&
      _errorAmount == null &&
      _targetWallet != null &&
      _targetWallet?.id != null &&
      amountController.text.isNotEmpty &&
      CurrencyFormatter.parseVND(amountController.text) > 0;

  String? get targetWalletId => _targetWallet?.id;

  void onTargetWalletSelected(String walletId) {
    _targetWallet = _availableWallets.firstWhere((w) => w.id == walletId);
    notifyListeners();
  }

  Future<void> transferMoney({required String sourceWalletId}) async {
    if (!isFormValid) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _walletRepo.transferMoney(
        sourceWalletId: sourceWalletId,
        targetWalletId: _targetWallet!.id,
        amount: CurrencyFormatter.parseVND(amountController.text),
      );
      _isSuccess = true;
      _successMessage = 'Transfer completed successfully';
    } catch (e) {
      _isSuccess = false;
      _successMessage = null;
      _errorTo = 'Failed to transfer money: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletsViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository;

  List<Wallet> _wallets = [];
  bool _isLoading = false;
  String? _error;
  double _totalBalance = 0.0;

  WalletsViewModel(this._walletRepository) {
    loadWallets();
  }

  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalBalance => _totalBalance;
  int get walletsCount => _wallets.length;

  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallets = await _walletRepository.getAllWallets();
      _calculateTotalBalance();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      await _walletRepository.createWallet(wallet);
      await loadWallets(); // Refresh after creation
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateWallet(Wallet oldWallet, Wallet updatedWallet) async {
    try {
      await _walletRepository.updateWallet(updatedWallet);
      await loadWallets(); // Refresh after update
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      await _walletRepository.deleteWallet(walletId);
      await loadWallets(); // Refresh after deletion
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Wallet>> searchWallets(String query) async {
    try {
      return await _walletRepository.searchWallets(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void _calculateTotalBalance() {
    _totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
  }

  void dispose() {
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../domain/wallet.dart';
import '../model/wallet_view_data.dart';

class WalletsViewModel extends ChangeNotifier {
  WalletsViewModel(this._repository);

  final WalletRepository _repository;

  String? _error;
  String? get error => _error;

  Stream<List<WalletViewData>> get walletsStream => _repository.watchAllWallets().map(
    (wallets) => wallets.map((wallet) => WalletViewData.fromDomain(wallet)).toList(),
  );
  Stream<int> get totalBalanceStream => walletsStream.map(
    (wallets) => wallets.fold(0, (sum, wallet) => sum + wallet.balance),
  );

  Stream<int> get walletsCountStream =>
      walletsStream.map((wallets) => wallets.length);

  void _handleError(Object e) {
    _error = e.toString();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      await _repository.createWallet(wallet);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _repository.updateWallet(wallet);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      await _repository.deleteWallet(walletId);
      clearError();
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletsViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository;

  List<Wallet> _wallets = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _error;
  String? _syncMessage;
  double _totalBalance = 0.0;

  WalletsViewModel(this._walletRepository) {
    loadWallets();
  }

  List<Wallet> get wallets => _wallets;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get error => _error;
  String? get syncMessage => _syncMessage;
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

  Future<void> syncToCloud(String userId) async {
    try {
      await _walletRepository.syncToCloud(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Bidirectional sync: Push local data to cloud (priority), then pull cloud data to local
  Future<void> bidirectionalSync(String userId) async {
    _isSyncing = true;
    _syncMessage = 'Starting sync...';
    _error = null;
    notifyListeners();

    try {
      // Step 1: Push local wallets to cloud (local data has priority)
      _syncMessage = 'Uploading local data to cloud...';
      notifyListeners();

      await _walletRepository.syncToCloud(userId);

      // Step 2: Pull new/updated data from cloud to local
      _syncMessage = 'Downloading updates from cloud...';
      notifyListeners();

      await _walletRepository.pullFromCloud(userId);

      // Step 3: Reload local data to reflect all changes
      _syncMessage = 'Refreshing local data...';
      notifyListeners();

      await loadWallets();

      _syncMessage = 'Sync completed successfully!';
      notifyListeners();

      // Clear sync message after delay
      await Future.delayed(const Duration(seconds: 2));
      _syncMessage = null;
      notifyListeners();
    } catch (e) {
      _error = 'Sync failed: $e';
      _syncMessage = null;
      notifyListeners();
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _calculateTotalBalance() {
    _totalBalance = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
  }

  void dispose() {
    super.dispose();
  }
}

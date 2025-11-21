import 'package:flutter/material.dart';
import '../../domain/entities/wallet.dart';

class WalletsViewModel extends ChangeNotifier {
  List<Wallet> _wallets = [];

  List<Wallet> get wallets => _wallets;

  double get totalBalance =>
      _wallets.fold<double>(0, (sum, w) => sum + w.balance);

  int get walletsCount => _wallets.length;

  void initializeWallets() {
    _wallets = [
      Wallet(
        id: '1',
        name: 'Main Bank Account',
        balance: 5230.75,
        createdOn: DateTime(2024, 10, 12),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        icon: Icons.account_balance,
        iconColor: Colors.blue,
      ),
      Wallet(
        id: '2',
        name: 'Momo Wallet',
        balance: 120.50,
        createdOn: DateTime(2025, 3, 2),
        lastUpdated: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        icon: Icons.mobile_friendly,
        iconColor: Colors.pink,
      ),
      Wallet(
        id: '3',
        name: 'Savings',
        balance: 15000.00,
        createdOn: DateTime(2023, 7, 18),
        lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
        icon: Icons.savings,
        iconColor: Colors.green,
      ),
      Wallet(
        id: '4',
        name: 'Crypto',
        balance: 980.42,
        createdOn: DateTime(2024, 1, 8),
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
        icon: Icons.currency_bitcoin,
        iconColor: Colors.orange,
      ),
    ];
    notifyListeners();
  }

  void deleteWallet(String walletId) {
    _wallets.removeWhere((w) => w.id == walletId);
    notifyListeners();
  }

  void updateWallet(Wallet updatedWallet) {
    final index = _wallets.indexWhere((w) => w.id == updatedWallet.id);
    if (index != -1) {
      _wallets[index] = updatedWallet;
      notifyListeners();
    }
  }

  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
  }
}

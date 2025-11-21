import 'package:flutter/material.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';
import '../../features/wallets/presentation/pages/add_wallet_page.dart';
import '../../features/wallets/presentation/pages/edit_wallet_page.dart';
import '../../features/wallets/presentation/pages/wallet_detail_page.dart';
import '../../features/wallets/presentation/pages/wallet_history_page.dart';
import '../../features/wallets/domain/entities/wallet.dart';

class AppRouter {
  static const String main = '/';
  static const String addTransaction = '/add-transaction';
  static const String addWallet = '/add-wallet';
  static const String editWallet = '/edit-wallet';
  static const String walletDetail = '/wallet-detail';
  static const String walletHistory = '/wallet-history';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionPage());

      case addWallet:
        return MaterialPageRoute(builder: (_) => const AddWalletPage());

      case editWallet:
        final args = settings.arguments as EditWalletArguments;
        return MaterialPageRoute(
          builder: (_) => EditWalletPage(
            walletName: args.walletName,
            balance: args.balance,
            currency: args.currency,
          ),
        );

      case walletDetail:
        final args = settings.arguments as WalletDetailArguments;
        return MaterialPageRoute(
          builder: (_) => WalletDetailPage(
            wallet: args.wallet,
            onEdit: args.onEdit,
            onDelete: args.onDelete,
            onHistory: args.onHistory,
          ),
        );

      case walletHistory:
        final walletName = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => WalletHistoryPage(walletName: walletName),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

// Route Arguments
class EditWalletArguments {
  final String walletName;
  final double balance;
  final String currency;

  const EditWalletArguments({
    required this.walletName,
    required this.balance,
    required this.currency,
  });
}

class WalletDetailArguments {
  final Wallet wallet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const WalletDetailArguments({
    required this.wallet,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });
}

import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/transactions/presentation/form/add_transaction_page.dart';
import '../../features/wallets/presentation/form/add_wallet_page.dart';
import '../../features/wallets/presentation/form/edit_wallet_page.dart';
import '../../features/wallets/presentation/detail/wallet_detail_page.dart';
import '../../features/wallets/presentation/history/wallet_history_page.dart';
import '../../features/wallets/domain/wallet.dart';
import '../di/injector.dart';

class AppRouter {
  static const String login = '/login';
  static const String main = '/';
  static const String addTransaction = '/add-transaction';
  static const String addWallet = '/add-wallet';
  static const String editWallet = '/edit-wallet';
  static const String walletDetail = '/wallet-detail';
  static const String walletHistory = '/wallet-history';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginPage(viewModel: getIt.get()),
        );

      case main:
        return MaterialPageRoute(builder: (_) => const MainScaffold());

      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionPage());

      case addWallet:
        return MaterialPageRoute(builder: (_) => const AddWalletPage());

      case editWallet:
        final wallet = settings.arguments as Wallet;
        return MaterialPageRoute(
          builder: (_) => EditWalletPage(wallet: wallet),
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
        final args = settings.arguments as WalletHistoryArguments;
        return MaterialPageRoute(
          builder: (_) => WalletHistoryPage(wallet: args.wallet),
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

class WalletHistoryArguments {
  final Wallet wallet;
  final String walletName;

  const WalletHistoryArguments({
    required this.wallet,
    required this.walletName,
  });
}

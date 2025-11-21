import 'package:flutter/material.dart';
import '../../features/main/presentation/pages/main_scaffold.dart';
import '../../features/transactions/presentation/pages/add_transaction_page.dart';

class AppRouter {
  static const String main = '/';
  static const String addTransaction = '/add-transaction';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainScaffold());
      case addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionPage());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

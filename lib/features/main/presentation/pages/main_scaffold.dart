import 'package:flutter/material.dart';
import '../../../../core/constants/navigation_items.dart';
import '../../../../core/widgets/bottom_navigation/custom_bottom_bar.dart';
import '../../../../core/widgets/custom_fab.dart';
import '../../../../core/di/injector.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../wallets/presentation/list/wallets_page.dart';
import '../../../transactions/presentation/list/transactions_page.dart';
import '../../../transactions/presentation/form/add_transaction_page.dart';
import '../../../transactions/presentation/list/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  // Use timestamp to force rebuild TransactionsPage when needed
  int _transactionsPageVersion = 0;

  List<Widget> get _pages => [
    const HomePage(),
    const WalletsPage(),
    TransactionsPage(key: ValueKey('transactions_$_transactionsPageVersion')),
    const CategoriesPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() async {
    // Navigate to add transaction page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );

    // Reload transactions if transaction was added successfully
    if (mounted && result == true) {
      final transactionsViewModel = getIt<TransactionsViewModel>();

      // Reload data first
      await transactionsViewModel.loadTransactions();

      // Force rebuild TransactionsPage and switch to it
      if (mounted) {
        setState(() {
          _transactionsPageVersion++; // Increment to force rebuild
          _selectedIndex = 2; // Transactions tab index
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: CustomFab(onPressed: _onFabPressed),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
        items: NavigationItems.mainNavItems,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'core/constants/navigation_items.dart';
import 'core/widgets/bottom_navigation/custom_bottom_bar.dart';
import 'core/widgets/custom_fab.dart';
import 'features/auth/presentation/home/home_page.dart';
import 'features/transactions/presentation/list/transactions_page.dart';
import 'features/transactions/presentation/form/add_transaction_page.dart';
import 'features/budget/presentation/list/budget_page.dart';
import 'features/user/presentation/user_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  int _transactionsPageVersion = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      TransactionsPage(key: ValueKey('transactions_$_transactionsPageVersion')),
      const BudgetPage(),
      const UserPage(),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );

    if (mounted && result == true) {
      if (mounted) {
        setState(() {
          _transactionsPageVersion++;
          _pages[1] = TransactionsPage(
            key: ValueKey('transactions_$_transactionsPageVersion'),
          );
          _selectedIndex = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
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

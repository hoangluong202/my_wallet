import 'package:flutter/material.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/constants/navigation_items.dart';
import '../../../../shared/widgets/bottom_navigation/custom_bottom_bar.dart';
import '../../../../shared/widgets/custom_fab.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../wallets/presentation/pages/wallets_page.dart';
import '../../../transactions/presentation/pages/transactions_page.dart';
import '../../../categories/presentation/pages/categories_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    WalletsPage(),
    TransactionsPage(),
    CategoriesPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabPressed() {
    Navigator.pushNamed(context, AppRouter.addTransaction);
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

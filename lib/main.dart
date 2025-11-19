import 'package:flutter/material.dart';

import 'home_page.dart';
import 'wallets_page.dart';
import 'transactions_page.dart';
import 'categories_page.dart';
import 'add_transaction_page.dart';
import 'notification_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
    );
  }

  void _showSuccessNotification(String message) {
    SuccessNotification.show(
      context: context,
      message: message,
      duration: const Duration(seconds: 3),
    );
  }

  Widget _buildBottomBar() {
    final items = [
      _BottomBarItem(label: 'Home', icon: Icons.home, index: 0),
      _BottomBarItem(
        label: 'Wallets',
        icon: Icons.account_balance_wallet,
        index: 1,
      ),
      _BottomBarItem(label: 'Transactions', icon: Icons.swap_horiz, index: 2),
      _BottomBarItem(label: 'Category', icon: Icons.category, index: 3),
    ];

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      padding: EdgeInsets.zero,
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          children: [
            // Home
            Expanded(
              flex: 1,
              child: _BottomNavItem(
                item: items[0],
                selected: _selectedIndex == 0,
                onTap: () => _onTabSelected(0),
              ),
            ),
            // Wallets - pushed to left with spacer
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: _BottomNavItem(
                  item: items[1],
                  selected: _selectedIndex == 1,
                  onTap: () => _onTabSelected(1),
                ),
              ),
            ),
            // Spacer for FAB
            const SizedBox(width: 60),
            // Transactions - pushed to right with spacer
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _BottomNavItem(
                  item: items[2],
                  selected: _selectedIndex == 2,
                  onTap: () => _onTabSelected(2),
                ),
              ),
            ),
            // Category
            Expanded(
              flex: 1,
              child: _BottomNavItem(
                item: items[3],
                selected: _selectedIndex == 3,
                onTap: () => _onTabSelected(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        elevation: 6,
        highlightElevation: 8,
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}

class _BottomBarItem {
  final String label;
  final IconData icon;
  final int index;

  _BottomBarItem({
    required this.label,
    required this.icon,
    required this.index,
  });
}

class _BottomNavItem extends StatelessWidget {
  final _BottomBarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final textColor = selected ? primaryColor : Colors.grey.shade500;
    final iconColor = selected ? primaryColor : Colors.grey.shade500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: selected ? 1.15 : 1.0,
                child: Icon(item.icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                height: 3,
                width: selected ? 22 : 0,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

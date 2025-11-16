import 'package:flutter/material.dart';

import 'home_page.dart';
import 'wallets_page.dart';
import 'transactions_page.dart';
import 'categories_page.dart';
import 'add_transaction_page.dart';

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
    // Navigate to Add Transaction page for all tabs
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTransactionPage()),
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
      notchMargin: 6.0,
      child: SizedBox(
        height: 60,
        child: Row(
          children: items.map((item) {
            final selected = _selectedIndex == item.index;
            final color = selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey;
            return Expanded(
              child: InkWell(
                onTap: () => _onTabSelected(item.index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        child: const Icon(Icons.add),
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

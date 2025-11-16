import 'package:flutter/material.dart';

import 'add_wallet_page.dart';
import 'edit_wallet_page.dart';
import 'wallet_history_page.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallets = [
      WalletModel(
        name: 'Main Bank Account',
        balance: 5230.75,
        createdOn: DateTime(2024, 10, 12),
        lastUpdated: const Duration(hours: 2),
      ),
      WalletModel(
        name: 'Momo Wallet',
        balance: 120.50,
        createdOn: DateTime(2025, 3, 2),
        lastUpdated: const Duration(days: 1, hours: 5),
      ),
      WalletModel(
        name: 'Savings',
        balance: 15000.00,
        createdOn: DateTime(2023, 7, 18),
        lastUpdated: const Duration(days: 7),
      ),
      WalletModel(
        name: 'Crypto',
        balance: 980.42,
        createdOn: DateTime(2024, 1, 8),
        lastUpdated: const Duration(minutes: 45),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Header with Add Wallet button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Wallets',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => _onAddWallet(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Wallet'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: wallets.length,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  return _buildWalletCard(context, wallet);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletPage()),
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletModel wallet) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(Icons.account_balance_wallet, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created on ${_formatDate(wallet.createdOn)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated ${_formatDuration(wallet.lastUpdated)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${wallet.balance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: wallet.balance < 0
                        ? Colors.red
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.history, size: 18),
                          SizedBox(width: 8),
                          Text('View History'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _onEditWallet(context, wallet);
                    } else if (value == 'view') {
                      _onViewHistory(context, wallet);
                    }
                  },
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onEditWallet(BuildContext context, WalletModel wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWalletPage(
          walletName: wallet.name,
          balance: wallet.balance,
          currency: 'VND (₫)',
        ),
      ),
    );
  }

  void _onViewHistory(BuildContext context, WalletModel wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletHistoryPage(walletName: wallet.name),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month]} ${date.year}';
  }

  static String _formatDuration(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes} minutes ago';
    if (d.inHours < 24) return '${d.inHours} hours ago';
    if (d.inDays < 7) return '${d.inDays} days ago';
    return '${d.inDays ~/ 7} weeks ago';
  }
}

class WalletModel {
  final String name;
  final double balance;
  final DateTime createdOn;
  final Duration lastUpdated;

  WalletModel({
    required this.name,
    required this.balance,
    required this.createdOn,
    required this.lastUpdated,
  });
}

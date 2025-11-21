import 'package:flutter/material.dart';

import 'add_wallet_page.dart';
import 'edit_wallet_page.dart';
import 'wallet_history_page.dart';
import 'wallet_detail_page.dart';
import 'notification_widget.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  late List<WalletModel> _wallets;

  @override
  void initState() {
    super.initState();
    _wallets = [
      WalletModel(
        name: 'Main Bank Account',
        balance: 5230.75,
        createdOn: DateTime(2024, 10, 12),
        lastUpdated: const Duration(hours: 2),
        icon: Icons.account_balance,
        iconColor: Colors.blue,
      ),
      WalletModel(
        name: 'Momo Wallet',
        balance: 120.50,
        createdOn: DateTime(2025, 3, 2),
        lastUpdated: const Duration(days: 1, hours: 5),
        icon: Icons.mobile_friendly,
        iconColor: Colors.pink,
      ),
      WalletModel(
        name: 'Savings',
        balance: 15000.00,
        createdOn: DateTime(2023, 7, 18),
        lastUpdated: const Duration(days: 7),
        icon: Icons.savings,
        iconColor: Colors.green,
      ),
      WalletModel(
        name: 'Crypto',
        balance: 980.42,
        createdOn: DateTime(2024, 1, 8),
        lastUpdated: const Duration(minutes: 45),
        icon: Icons.currency_bitcoin,
        iconColor: Colors.orange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildTopBar(context),
              const SizedBox(height: 12),
              _buildSummaryCard(context),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _wallets.length,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (context, index) {
                    final wallet = _wallets[index];
                    return _buildWalletCard(context, wallet);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Wallets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        FilledButton.icon(
          onPressed: () => _onAddWallet(context),
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final total = _wallets.fold<double>(0, (sum, w) => sum + w.balance);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('${_wallets.length} wallets'),
            ],
          ),
          Text(
            '${_formatVND(total.toInt())} đ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: total < 0 ? Colors.red : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _onAddWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWalletPage()),
    ).then((result) {
      if (result == true) {
        SuccessNotification.show(
          context: context,
          message: 'Wallet created successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  Widget _buildWalletCard(BuildContext context, WalletModel wallet) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WalletDetailPage(
              wallet: wallet,
              onEdit: () => _onEditWallet(context, wallet),
              onDelete: () => _onDeleteWallet(wallet),
              onHistory: () => _onViewHistory(context, wallet),
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: wallet.iconColor.withOpacity(0.2),
                child: Icon(wallet.icon, size: 20, color: wallet.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Created on ${_formatDate(wallet.createdOn)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Last updated ${_formatDuration(wallet.lastUpdated)}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatVND(wallet.balance.toInt())} đ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: wallet.balance < 0
                          ? Colors.red
                          : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    ).then((result) {
      if (result == true) {
        SuccessNotification.show(
          context: context,
          message: 'Wallet "${wallet.name}" updated successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    });
  }

  void _onViewHistory(BuildContext context, WalletModel wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletHistoryPage(walletName: wallet.name),
      ),
    );
  }

  void _onDeleteWallet(WalletModel wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet?'),
        content: const Text(
          'Are you sure you want to delete this wallet? '
          'All transactions associated with this wallet will also be deleted. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _wallets.removeWhere((w) => w.name == wallet.name);
              });
              SuccessNotification.show(
                context: context,
                message: 'Wallet "${wallet.name}" deleted successfully!',
                duration: const Duration(seconds: 2),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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

  static String _formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }
}

class WalletModel {
  final String name;
  final double balance;
  final DateTime createdOn;
  final Duration lastUpdated;
  final IconData icon;
  final Color iconColor;

  WalletModel({
    required this.name,
    required this.balance,
    required this.createdOn,
    required this.lastUpdated,
    this.icon = Icons.account_balance_wallet,
    this.iconColor = Colors.blue,
  });
}

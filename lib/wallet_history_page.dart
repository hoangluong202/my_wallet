import 'package:flutter/material.dart';

class WalletHistoryPage extends StatelessWidget {
  final String walletName;
  final double balance;
  final String currency;
  final IconData? icon;
  final Color? iconColor;

  const WalletHistoryPage({
    super.key,
    required this.walletName,
    this.balance = 0.0,
    this.currency = 'VND (₫)',
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final historyEntries = _getHistoryData();

    return Scaffold(
      appBar: AppBar(
        title: Text('$walletName History'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Wallet Icon and Info Header
              CircleAvatar(
                radius: 45,
                backgroundColor: (iconColor ?? Colors.blue).withOpacity(0.2),
                child: Icon(
                  icon ?? Icons.account_balance_wallet,
                  size: 56,
                  color: iconColor ?? Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              
              // Wallet Name
              Text(
                walletName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Balance and Currency
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currency,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 28),
              
              // Change Log Title
              Text(
                'Change Log',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Column(
                children: historyEntries
                    .map((entry) => _buildHistoryCard(context, entry))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HistoryEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(entry.type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(entry.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${entry.dateTime.toString().split('.')[0]}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Old Value:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        entry.oldValue,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'New Value:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        entry.newValue,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (entry.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${entry.notes}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'Balance Updated':
        return Colors.blue;
      case 'Name Changed':
        return Colors.orange;
      case 'Currency Changed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<HistoryEntry> _getHistoryData() {
    final now = DateTime.now();
    return [
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(hours: 2)),
        oldValue: '\$5,200.00',
        newValue: '\$5,230.75',
        notes: 'Deposit from salary',
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 1)),
        oldValue: '\$5,450.50',
        newValue: '\$5,200.00',
        notes: 'Withdrawal for bills',
      ),
      HistoryEntry(
        type: 'Name Changed',
        status: 'Rename',
        dateTime: now.subtract(const Duration(days: 3)),
        oldValue: 'Main Account',
        newValue: 'Main Bank Account',
        notes: null,
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 5)),
        oldValue: '\$3,200.00',
        newValue: '\$5,450.50',
        notes: 'Transfer from savings',
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 7)),
        oldValue: '\$5,000.00',
        newValue: '\$3,200.00',
        notes: 'Shopping expenses',
      ),
      HistoryEntry(
        type: 'Currency Changed',
        status: 'Change',
        dateTime: now.subtract(const Duration(days: 10)),
        oldValue: 'USD (\$)',
        newValue: 'VND (₫)',
        notes: null,
      ),
    ];
  }
}

class HistoryEntry {
  final String type;
  final String status;
  final DateTime dateTime;
  final String oldValue;
  final String newValue;
  final String? notes;

  HistoryEntry({
    required this.type,
    required this.status,
    required this.dateTime,
    required this.oldValue,
    required this.newValue,
    this.notes,
  });
}

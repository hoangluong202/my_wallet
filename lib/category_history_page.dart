import 'package:flutter/material.dart';
import 'categories_page.dart';

class TransactionHistory {
  final double amount;
  final DateTime date;
  final String description;
  final String type; // income, expense, debt, loan

  TransactionHistory({
    required this.amount,
    required this.date,
    required this.description,
    required this.type,
  });
}

class CategoryHistoryPage extends StatelessWidget {
  final CategoryItem category;

  const CategoryHistoryPage({super.key, required this.category});

  List<TransactionHistory> _getMockTransactions() {
    final now = DateTime.now();
    return [
      TransactionHistory(
        amount: 25.50,
        date: now,
        description: 'Lunch with friends',
        type: 'expense',
      ),
      TransactionHistory(
        amount: 4.50,
        date: now.subtract(const Duration(hours: 2)),
        description: 'Morning coffee',
        type: 'expense',
      ),
      TransactionHistory(
        amount: 87.23,
        date: now.subtract(const Duration(days: 1)),
        description: 'Grocery shopping',
        type: 'expense',
      ),
      TransactionHistory(
        amount: 55.00,
        date: now.subtract(const Duration(days: 2)),
        description: 'Gas station',
        type: 'expense',
      ),
      TransactionHistory(
        amount: 3500.00,
        date: now.subtract(const Duration(days: 5)),
        description: 'Monthly salary',
        type: 'income',
      ),
    ];
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
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
      return '${months[date.month]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getMockTransactions();
    final grouped = <String, List<TransactionHistory>>{};

    for (final t in transactions) {
      final label = _getDateLabel(t.date);
      if (!grouped.containsKey(label)) grouped[label] = [];
      grouped[label]!.add(t);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} History'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Transaction History',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...grouped.entries.map((entry) {
                final dateLabel = entry.key;
                final txns = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    ...txns.map((txn) {
                      final isIncome = txn.type == 'income';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                isIncome
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(txn.description),
                            subtitle: Text(
                              '${txn.date.hour}:${txn.date.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            trailing: Text(
                              '${isIncome ? '+' : '-'}\$${txn.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

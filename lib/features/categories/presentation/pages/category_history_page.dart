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
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  String _formatVND(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${category.transactionCount} transactions',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, size: 18, color: category.color),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...grouped.entries.map((entry) {
                        final dateLabel = entry.key;
                        final txns = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 12.0,
                                bottom: 8.0,
                              ),
                              child: Text(
                                dateLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            ...txns.map((txn) {
                              final isIncome = txn.type == 'income';
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Icon(
                                        isIncome
                                            ? Icons.trending_up
                                            : Icons.trending_down,
                                        size: 16,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            txn.description,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${txn.date.hour.toString().padLeft(2, '0')}:${txn.date.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isIncome ? '+' : '-'}${_formatVND(txn.amount)}đ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isIncome
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: const _TransactionsContent(),
    );
  }
}

class _TransactionsContent extends StatelessWidget {
  const _TransactionsContent();

  @override
  Widget build(BuildContext context) {
    // Dummy data: total balance and today's spending
    const totalBalance = 12845.50;
    const todaySpending = 127.50;

    // Grouped transactions by date
    final transactionsByDate = _getGroupedTransactions();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$$totalBalance',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Today's Spending: \$$todaySpending",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),

          // Transactions grouped by date
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            child: Text(
              'Transaction History',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Build grouped transactions
          Column(
            children: transactionsByDate.entries.map((entry) {
              final dateGroup = entry.key;
              final transactions = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Text(
                      dateGroup,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),

                  // Transactions for this date
                  ...transactions.map((transaction) {
                    return _buildTransactionCard(context, transaction);
                  }).toList(),

                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),

          // Extra padding at bottom for scrolling
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionItem transaction,
  ) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? Colors.red : Colors.green.shade600;
    final backgroundColor = isExpense
        ? Colors.red.shade50
        : Colors.green.shade50;
    final borderColor = isExpense ? Colors.red.shade200 : Colors.green.shade200;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Category icon
            Container(
              decoration: BoxDecoration(
                color: isExpense ? Colors.red.shade200 : Colors.green.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                transaction.categoryIcon,
                color: isExpense ? Colors.red.shade800 : Colors.green.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),

            // Description and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Return transactions grouped by date
  Map<String, List<TransactionItem>> _getGroupedTransactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));

    final transactions = [
      // Today's transactions
      TransactionItem(
        description: 'Lunch with friends',
        category: 'Food',
        amount: 25.50,
        type: TransactionType.expense,
        categoryIcon: Icons.restaurant,
        date: today,
      ),
      TransactionItem(
        description: 'Coffee',
        category: 'Food',
        amount: 4.50,
        type: TransactionType.expense,
        categoryIcon: Icons.coffee,
        date: today,
      ),
      TransactionItem(
        description: 'Grocery shopping',
        category: 'Shopping',
        amount: 97.50,
        type: TransactionType.expense,
        categoryIcon: Icons.shopping_cart,
        date: today,
      ),

      // Yesterday's transactions
      TransactionItem(
        description: 'Taxi ride',
        category: 'Transport',
        amount: 15.00,
        type: TransactionType.expense,
        categoryIcon: Icons.directions_car,
        date: yesterday,
      ),
      TransactionItem(
        description: 'Monthly salary',
        category: 'Income',
        amount: 3500.00,
        type: TransactionType.income,
        categoryIcon: Icons.trending_up,
        date: yesterday,
      ),

      // Two days ago
      TransactionItem(
        description: 'Gas station',
        category: 'Transport',
        amount: 45.00,
        type: TransactionType.expense,
        categoryIcon: Icons.local_gas_station,
        date: twoDaysAgo,
      ),
      TransactionItem(
        description: 'Freelance project payment',
        category: 'Income',
        amount: 250.00,
        type: TransactionType.income,
        categoryIcon: Icons.work,
        date: twoDaysAgo,
      ),
      TransactionItem(
        description: 'Movie tickets',
        category: 'Entertainment',
        amount: 30.00,
        type: TransactionType.expense,
        categoryIcon: Icons.movie,
        date: twoDaysAgo,
      ),
    ];

    // Group transactions by date label
    final grouped = <String, List<TransactionItem>>{};

    for (final transaction in transactions) {
      final dateLabel = _getDateLabel(transaction.date);
      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }
      grouped[dateLabel]!.add(transaction);
    }

    return grouped;
  }

  /// Format date as readable label
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
      // Format as "Nov 10, 2025"
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
}

enum TransactionType { income, expense }

class TransactionItem {
  final String description;
  final String category;
  final double amount;
  final TransactionType type;
  final IconData categoryIcon;
  final DateTime date;

  TransactionItem({
    required this.description,
    required this.category,
    required this.amount,
    required this.type,
    required this.categoryIcon,
    required this.date,
  });
}

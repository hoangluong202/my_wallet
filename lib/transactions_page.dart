import 'package:flutter/material.dart';
import 'edit_transaction_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Total Balance Display Card - Enhanced
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Stack(
              children: [
                // Blurred background effect
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 200,
                ),
                // Main card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Total Balance',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₫12,845.50',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 42,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white.withOpacity(0.8),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: LinearProgressIndicator(
                              value: 0.75,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget usage: 75%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.trending_up,
                              color: Colors.white.withOpacity(0.8),
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar - Enhanced
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Past'),
                Tab(text: 'Today'),
                Tab(text: 'Future'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TransactionsTabContent(tabType: TabType.past),
                _TransactionsTabContent(tabType: TabType.today),
                _TransactionsTabContent(tabType: TabType.future),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum TabType { past, today, future }

class _TransactionsTabContent extends StatelessWidget {
  final TabType tabType;

  const _TransactionsTabContent({required this.tabType});

  @override
  Widget build(BuildContext context) {
    final transactionsByDate = _getGroupedTransactions(tabType);

    if (transactionsByDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found for this period',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: transactionsByDate.length,
      itemBuilder: (context, index) {
        final entry = transactionsByDate.entries.elementAt(index);
        final dateGroup = entry.key;
        final transactions = entry.value;

        // Calculate totals for this date group
        double totalIncome = 0;
        double totalExpense = 0;

        for (final transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            totalIncome += transaction.amount;
          } else {
            totalExpense += transaction.amount;
          }
        }

        final netDifference = totalIncome - totalExpense;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Group Header
            _buildDateGroupHeader(
              context,
              dateGroup,
              totalIncome,
              totalExpense,
              netDifference,
            ),
            const SizedBox(height: 12),

            // Transaction Items
            ...transactions.map((transaction) {
              return _buildTransactionItem(context, transaction);
            }).toList(),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildDateGroupHeader(
    BuildContext context,
    String dateGroup,
    double totalIncome,
    double totalExpense,
    double netDifference,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateGroup,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: netDifference >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${netDifference >= 0 ? '+' : ''} ₫${netDifference.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: netDifference >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                icon: Icons.trending_up,
                label: 'Income',
                amount: totalIncome,
                color: Colors.green,
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildSummaryItem(
                icon: Icons.trending_down,
                label: 'Expense',
                amount: totalExpense,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₫${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionItem transaction,
  ) {
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isExpense ? Colors.red : Colors.green.shade700;
    final bgColor = isExpense ? Colors.red.shade50 : Colors.green.shade50;

    return GestureDetector(
      onLongPress: () {
        _showTransactionOptions(context, transaction);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Leading Icon
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  transaction.categoryIcon,
                  color: amountColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'} ₫${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isExpense ? 'Expense' : 'Income',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
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

  void _showTransactionOptions(
    BuildContext context,
    TransactionItem transaction,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Transaction details preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: transaction.type == TransactionType.expense
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          transaction.categoryIcon,
                          color: transaction.type == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.category,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              transaction.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${transaction.type == TransactionType.expense ? '-' : '+'} ₫${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 8),

                // Edit Button
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.edit,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Edit Transaction',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Modify this transaction',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onEditTransaction(context, transaction);
                  },
                ),
                const SizedBox(height: 8),

                // Delete Button
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red.shade700,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Delete Transaction',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: Text(
                    'Remove this transaction',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _onDeleteTransaction(context, transaction);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onEditTransaction(
    BuildContext context,
    TransactionItem transaction,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    );
  }

  void _onDeleteTransaction(
    BuildContext context,
    TransactionItem transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
          'Are you sure you want to delete "${transaction.description}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Transaction "${transaction.description}" deleted',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<TransactionItem>> _getGroupedTransactions(TabType tabType) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    const twoDaysAgo = Duration(days: 2);
    final tomorrowDate = today.add(const Duration(days: 1));

    final allTransactions = [
      // Past transactions (before today)
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
      TransactionItem(
        description: 'Gas station',
        category: 'Transport',
        amount: 45.00,
        type: TransactionType.expense,
        categoryIcon: Icons.local_gas_station,
        date: today.subtract(twoDaysAgo),
      ),
      TransactionItem(
        description: 'Freelance project payment',
        category: 'Income',
        amount: 250.00,
        type: TransactionType.income,
        categoryIcon: Icons.work,
        date: today.subtract(twoDaysAgo),
      ),
      TransactionItem(
        description: 'Movie tickets',
        category: 'Entertainment',
        amount: 30.00,
        type: TransactionType.expense,
        categoryIcon: Icons.movie,
        date: today.subtract(twoDaysAgo),
      ),

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

      // Future transactions (after today)
      TransactionItem(
        description: 'Scheduled transfer',
        category: 'Transfer',
        amount: 500.00,
        type: TransactionType.expense,
        categoryIcon: Icons.send,
        date: tomorrowDate,
      ),
      TransactionItem(
        description: 'Bonus payment',
        category: 'Income',
        amount: 1000.00,
        type: TransactionType.income,
        categoryIcon: Icons.trending_up,
        date: tomorrowDate.add(const Duration(days: 3)),
      ),
    ];

    // Filter transactions based on tab type
    final filteredTransactions = allTransactions.where((transaction) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      switch (tabType) {
        case TabType.past:
          return transactionDate.isBefore(today);
        case TabType.today:
          return transactionDate.isAtSameMomentAs(today);
        case TabType.future:
          return transactionDate.isAfter(today);
      }
    }).toList();

    // Group filtered transactions by date
    final grouped = <String, List<TransactionItem>>{};

    for (final transaction in filteredTransactions) {
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

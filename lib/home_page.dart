import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Total Balance Section
            _buildBalanceSection(context),
            const SizedBox(height: 24),

            // Wallets Horizontal Scroll
            _buildWalletsSection(context),
            const SizedBox(height: 24),

            // Income vs Expense Chart
            _buildChartSection(context),
            const SizedBox(height: 24),

            // Recent Transactions
            _buildRecentTransactionsSection(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    const totalBalance = 12845.50;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$$totalBalance',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsSection(BuildContext context) {
    final wallets = [
      _Wallet(name: 'Checking', balance: 5320.00, icon: Icons.account_balance),
      _Wallet(name: 'Savings', balance: 7525.50, icon: Icons.savings),
      _Wallet(name: 'Credit Card', balance: -500.00, icon: Icons.credit_card),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'My Wallets',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children:
                wallets
                    .map((wallet) => _buildWalletCard(context, wallet))
                    .toList()
                    .expand((widget) => [widget, const SizedBox(width: 12)])
                    .toList()
                  ..removeLast(),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, _Wallet wallet) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(wallet.icon, size: 32, color: Colors.blue),
          const SizedBox(height: 12),
          Text(
            wallet.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${wallet.balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: wallet.balance < 0 ? Colors.red : Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income vs Expense',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: BarChart(
              BarChartData(
                barGroups: _getBarChartData(),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                        ];
                        return Text(
                          months[value.toInt() % months.length],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarChartData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(toY: 3000, color: Colors.green, width: 8),
          BarChartRodData(toY: 2200, color: Colors.red, width: 8),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(toY: 2800, color: Colors.green, width: 8),
          BarChartRodData(toY: 2400, color: Colors.red, width: 8),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(toY: 3500, color: Colors.green, width: 8),
          BarChartRodData(toY: 2100, color: Colors.red, width: 8),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(toY: 3200, color: Colors.green, width: 8),
          BarChartRodData(toY: 2300, color: Colors.red, width: 8),
        ],
      ),
      BarChartGroupData(
        x: 4,
        barRods: [
          BarChartRodData(toY: 3100, color: Colors.green, width: 8),
          BarChartRodData(toY: 2600, color: Colors.red, width: 8),
        ],
      ),
      BarChartGroupData(
        x: 5,
        barRods: [
          BarChartRodData(toY: 3800, color: Colors.green, width: 8),
          BarChartRodData(toY: 2900, color: Colors.red, width: 8),
        ],
      ),
    ];
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    final transactions = [
      _Transaction(
        name: 'Coffee',
        amount: -4.50,
        date: 'Today, 10:30 AM',
        type: _TransactionType.expense,
        icon: Icons.coffee,
      ),
      _Transaction(
        name: 'Salary',
        amount: 3500.00,
        date: 'Yesterday, 09:00 AM',
        type: _TransactionType.income,
        icon: Icons.trending_up,
      ),
      _Transaction(
        name: 'Grocery',
        amount: -87.23,
        date: '2 days ago',
        type: _TransactionType.expense,
        icon: Icons.shopping_cart,
      ),
      _Transaction(
        name: 'Freelance Work',
        amount: 250.00,
        date: '3 days ago',
        type: _TransactionType.income,
        icon: Icons.work,
      ),
      _Transaction(
        name: 'Gas',
        amount: -55.00,
        date: '5 days ago',
        type: _TransactionType.expense,
        icon: Icons.local_gas_station,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: transactions
                .map((t) => _buildTransactionTile(t))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_Transaction transaction) {
    final isIncome = transaction.type == _TransactionType.income;
    final amountColor = isIncome ? Colors.green : Colors.red;
    final backgroundColor = isIncome
        ? Colors.green.shade50
        : Colors.red.shade50;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          border: Border.all(
            color: isIncome ? Colors.green.shade200 : Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isIncome ? Colors.green.shade200 : Colors.red.shade200,
              ),
              child: Icon(
                transaction.icon,
                color: isIncome ? Colors.green.shade800 : Colors.red.shade800,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
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
}

class _Wallet {
  final String name;
  final double balance;
  final IconData icon;
  const _Wallet({
    required this.name,
    required this.balance,
    required this.icon,
  });
}

enum _TransactionType { income, expense }

class _Transaction {
  final String name;
  final double amount;
  final String date;
  final _TransactionType type;
  final IconData icon;
  const _Transaction({
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.icon,
  });
}

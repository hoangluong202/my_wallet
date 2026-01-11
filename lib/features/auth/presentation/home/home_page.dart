import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/app_router.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../transactions/presentation/viewmodel/transactions_viewmodel.dart';
import '../../../../core/widgets/notification_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserViewModel _userViewModel;
  late final WalletsViewModel _walletsViewModel;
  late final AuthViewModel _authViewModel;
  late final TransactionsViewModel _transactionsViewModel;

  // Selected month for charts
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedPieChartMonth = DateTime.now();

  // Chart visibility toggles
  bool _showIncome = true;
  bool _showExpense = true;

  @override
  void initState() {
    super.initState();
    _userViewModel = getIt<UserViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();
    _authViewModel = getIt<AuthViewModel>();
    _transactionsViewModel = getIt<TransactionsViewModel>();
  }

  Future<void> _syncData(BuildContext context) async {
    try {
      final authViewModel = getIt<AuthViewModel>();
      final currentUser = authViewModel.currentUser;

      if (currentUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user logged in'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Sync completed: Local ↔ Cloud',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserHeader(context),
            const SizedBox(height: 16),
            _buildBalanceCards(context),
            const SizedBox(height: 20),
            _buildIncomeExpenseChart(context),
            const SizedBox(height: 20),
            _buildCategoryPieChart(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: ListenableBuilder(
            listenable: _authViewModel,
            builder: (context, _) {
              final userName =
                  _authViewModel.currentUser?.displayName ?? 'User';
              final initials = _getInitials(userName);

              return Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: _walletsViewModel,
                    builder: (context, _) {
                      return IconButton(
                        onPressed: () => _syncData(context),
                        icon: SizedBox(
                          width: 20,
                          height: 20,
                          child: Icon(
                            Icons.sync,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'signout') {
                        final authViewModel = getIt.get<AuthViewModel>();

                        // Clear ViewModels state
                        _userViewModel.clear();

                        // Sign out (this will also clear all local data)
                        await authViewModel.signOut();

                        if (context.mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRouter.login,
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        height: 10,
                        value: 'signout',
                        padding: EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 4),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    iconSize: 20,
                    tooltip: 'Menu',
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 60),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'U';
  }

  Widget _buildBalanceCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StreamBuilder<int>(
                    stream: _walletsViewModel.totalBalanceStream,
                    initialData: 0,
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return Text(
                        _formatVND(total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: StreamBuilder<Map<int, Map<String, int>>>(
          stream: _transactionsViewModel.watchDailyIncomeExpenseByMonth(
            _selectedMonth.year,
            _selectedMonth.month,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final dailyData = snapshot.data!;
            final daysInMonth = DateTime(
              _selectedMonth.year,
              _selectedMonth.month + 1,
              0,
            ).day;

            // Convert map to list for chart
            final chartData = List.generate(daysInMonth, (index) {
              final day = index + 1;
              final dayData = dailyData[day] ?? {'income': 0, 'expense': 0};
              return {
                'day': day,
                'income': dayData['income'] ?? 0,
                'expense': dayData['expense'] ?? 0,
              };
            });

            // Calculate max value for chart scaling based on visible data
            double maxValue = 0;

            if (_showIncome && _showExpense) {
              // Both visible: use the max of both
              final maxIncome = chartData.isEmpty
                  ? 0
                  : chartData
                        .map((e) => e['income'] as int)
                        .reduce((a, b) => a > b ? a : b);
              final maxExpense = chartData.isEmpty
                  ? 0
                  : chartData
                        .map((e) => e['expense'] as int)
                        .reduce((a, b) => a > b ? a : b);
              maxValue = (maxIncome > maxExpense ? maxIncome : maxExpense)
                  .toDouble();
            } else if (_showIncome) {
              // Only income visible: use max income
              final maxIncome = chartData.isEmpty
                  ? 0
                  : chartData
                        .map((e) => e['income'] as int)
                        .reduce((a, b) => a > b ? a : b);
              maxValue = maxIncome.toDouble();
            } else if (_showExpense) {
              // Only expense visible: use max expense
              final maxExpense = chartData.isEmpty
                  ? 0
                  : chartData
                        .map((e) => e['expense'] as int)
                        .reduce((a, b) => a > b ? a : b);
              maxValue = maxExpense.toDouble();
            }

            // Handle case when there's no data
            final displayMaxValue = maxValue > 0 ? maxValue : 1000000;
            final interval = (displayMaxValue / 4).ceilToDouble();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with month selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Income & Expense',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: 22,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month - 1,
                              );
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedMonth = DateTime(
                                _selectedMonth.year,
                                _selectedMonth.month + 1,
                              );
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Legend with toggles
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggleLegendItem(
                      Colors.green.shade600,
                      'Income',
                      _showIncome,
                      (value) {
                        setState(() {
                          _showIncome = value;
                          // At least one must be shown
                          if (!_showIncome && !_showExpense) {
                            _showExpense = true;
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildToggleLegendItem(
                      Colors.red.shade600,
                      'Expense',
                      _showExpense,
                      (value) {
                        setState(() {
                          _showExpense = value;
                          // At least one must be shown
                          if (!_showIncome && !_showExpense) {
                            _showIncome = true;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Line Chart
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        // Left titles (Y-axis - Amount)
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              if (value >= 1000000) {
                                return Text(
                                  '${(value / 1000000).toStringAsFixed(1)}M',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }
                              return Text(
                                '${(value / 1000).toInt()}K',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ),
                        // Bottom titles (X-axis - Days)
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: daysInMonth > 15
                                ? 5
                                : 3, // Show every 5 days if >15 days, else every 3
                            getTitlesWidget: (value, meta) {
                              final day = value.toInt() + 1;
                              if (day < 1 || day > daysInMonth) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                          left: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: (daysInMonth - 1).toDouble(),
                      minY: 0,
                      maxY: displayMaxValue * 1.15, // Add 15% padding on top
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (touchedSpot) =>
                              Colors.grey.shade800,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final dayIndex = spot.x.toInt();
                              final day = chartData[dayIndex]['day'];
                              final value = spot.y.toInt();

                              // Determine label based on color
                              String label;
                              if (spot.bar.color == Colors.green.shade600) {
                                label = 'Income';
                              } else {
                                label = 'Expense';
                              }

                              return LineTooltipItem(
                                'Day $day\n$label: ${_formatVND(value)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // Income line
                        if (_showIncome)
                          LineChartBarData(
                            spots: List.generate(
                              chartData.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                (chartData[index]['income'] as int).toDouble(),
                              ),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.green.shade600,
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show:
                                  daysInMonth <=
                                  15, // Only show dots if <= 15 days
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 1.5,
                                  strokeColor: Colors.green.shade600,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade600.withOpacity(0.15),
                                  Colors.green.shade600.withOpacity(0.03),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        // Expense line
                        if (_showExpense)
                          LineChartBarData(
                            spots: List.generate(
                              chartData.length,
                              (index) => FlSpot(
                                index.toDouble(),
                                (chartData[index]['expense'] as int).toDouble(),
                              ),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            color: Colors.red.shade600,
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show:
                                  daysInMonth <=
                                  15, // Only show dots if <= 15 days
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 1.5,
                                  strokeColor: Colors.red.shade600,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade600.withOpacity(0.15),
                                  Colors.red.shade600.withOpacity(0.03),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (_showIncome) ...[
                        _buildSummaryItem(
                          'Total Income',
                          chartData.fold<int>(
                            0,
                            (sum, item) => sum + (item['income'] as int),
                          ),
                          Colors.green.shade600,
                        ),
                        if (_showExpense)
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                      ],
                      if (_showExpense)
                        _buildSummaryItem(
                          'Total Expense',
                          chartData.fold<int>(
                            0,
                            (sum, item) => sum + (item['expense'] as int),
                          ),
                          Colors.red.shade600,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  Widget _buildSummaryItem(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatVND(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: StreamBuilder<Map<String, int>>(
          stream: _transactionsViewModel.watchCategoryExpensesByMonth(
            _selectedPieChartMonth.year,
            _selectedPieChartMonth.month,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final categoryExpenses = snapshot.data!;

            // If no data, show empty state
            if (categoryExpenses.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with month selector
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense by Category',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              size: 22,
                              color: Colors.grey.shade700,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPieChartMonth = DateTime(
                                  _selectedPieChartMonth.year,
                                  _selectedPieChartMonth.month - 1,
                                );
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_getMonthName(_selectedPieChartMonth.month)} ${_selectedPieChartMonth.year}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              size: 22,
                              color: Colors.grey.shade700,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedPieChartMonth = DateTime(
                                  _selectedPieChartMonth.year,
                                  _selectedPieChartMonth.month + 1,
                                );
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expense data',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            }

            // Prepare data with colors
            final colorPalette = [
              Colors.orange,
              Colors.blue,
              Colors.purple,
              Colors.pink,
              Colors.teal,
              Colors.amber,
              Colors.cyan,
              Colors.indigo,
              Colors.lime,
              Colors.deepOrange,
            ];

            final categories = categoryExpenses.entries.toList();
            final categoriesWithColors = List.generate(categories.length, (
              index,
            ) {
              return {
                'name': categories[index].key,
                'amount': categories[index].value,
                'color': colorPalette[index % colorPalette.length],
              };
            });

            final total = categoryExpenses.values.fold<int>(
              0,
              (sum, amount) => sum + amount,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with month selector
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense by Category',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left,
                            size: 22,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedPieChartMonth = DateTime(
                                _selectedPieChartMonth.year,
                                _selectedPieChartMonth.month - 1,
                              );
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_getMonthName(_selectedPieChartMonth.month)} ${_selectedPieChartMonth.year}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: Colors.grey.shade700,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedPieChartMonth = DateTime(
                                _selectedPieChartMonth.year,
                                _selectedPieChartMonth.month + 1,
                              );
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pie chart centered
                Center(
                  child: SizedBox(
                    height: 200,
                    width: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 60,
                        sections: categoriesWithColors.map((category) {
                          final amount = category['amount'] as int;
                          final percentage = (amount / total * 100)
                              .toStringAsFixed(0);
                          return PieChartSectionData(
                            value: amount.toDouble(),
                            title: '$percentage%',
                            color: category['color'] as Color,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category list - vertical layout for better readability
                ...categoriesWithColors.map((category) {
                  final amount = category['amount'] as int;
                  final percentage = (amount / total * 100).toStringAsFixed(1);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: category['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['name'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatVND(amount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Total summary
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 20,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total Expense',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatVND(total),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleLegendItem(
    Color color,
    String label,
    bool isSelected,
    Function(bool) onToggle,
  ) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVND(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formatted đ';
  }
}

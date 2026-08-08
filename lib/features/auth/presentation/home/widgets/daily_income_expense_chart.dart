import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../categories/domain/category.dart';
import '../../../../transactions/presentation/model/transaction_view_data.dart';
import '../../../../transactions/presentation/viewmodel/transactions_viewmodel.dart';

class DailyIncomeExpenseChart extends StatelessWidget {
  const DailyIncomeExpenseChart({
    super.key,
    required this.transactionsViewModel,
  });

  final TransactionsViewModel transactionsViewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
        child: StreamBuilder<List<TransactionViewData>>(
          stream: transactionsViewModel.watchAllTransactions(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final transactions = snapshot.data!;
            final now = DateTime.now();
            final transactionMonths = transactions
                .map(
                  (transaction) => DateTime(
                    transaction.transactionDate.year,
                    transaction.transactionDate.month,
                  ),
                )
                .toList();
            final firstMonth = transactionMonths.isEmpty
                ? DateTime(now.year, now.month)
                : transactionMonths.reduce((a, b) => a.isBefore(b) ? a : b);
            final lastTransactionMonth = transactionMonths.isEmpty
                ? DateTime(now.year, now.month)
                : transactionMonths.reduce((a, b) => a.isAfter(b) ? a : b);
            final currentMonth = DateTime(now.year, now.month);
            final lastMonth = lastTransactionMonth.isAfter(currentMonth)
                ? lastTransactionMonth
                : currentMonth;
            final months = <DateTime>[
              for (
                var month = firstMonth;
                !month.isAfter(lastMonth);
                month = DateTime(month.year, month.month + 1)
              )
                month,
            ];

            final monthlyData = months.map((date) {
              final monthTransactions = transactions.where((transaction) {
                return transaction.transactionDate.year == date.year &&
                    transaction.transactionDate.month == date.month;
              }).toList();

              final income = monthTransactions.fold<int>(0, (sum, transaction) {
                final type = transaction.category.type;
                if (type == CategoryType.income || type == CategoryType.debt) {
                  return sum + transaction.amount;
                }
                return sum;
              });

              final expense = monthTransactions.fold<int>(0, (
                sum,
                transaction,
              ) {
                final type = transaction.category.type;
                if (type == CategoryType.expense || type == CategoryType.loan) {
                  return sum + transaction.amount;
                }
                return sum;
              });

              return {
                'year': date.year,
                'month': date.month,
                'income': income,
                'expense': expense,
              };
            }).toList();

            final maxValue = [
              monthlyData.fold<int>(
                0,
                (max, item) => max > (item['income'] as int)
                    ? max
                    : (item['income'] as int),
              ),
              monthlyData.fold<int>(
                0,
                (max, item) => max > (item['expense'] as int)
                    ? max
                    : (item['expense'] as int),
              ),
            ].fold<int>(0, (max, value) => value > max ? value : max);

            final displayMaxValue = maxValue > 0
                ? maxValue.toDouble()
                : 1000000.0;
            final interval = (displayMaxValue / 4).ceilToDouble();
            final chartWidth = 40 + monthlyData.length * 76.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income & Expense by Month',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 4),
                  child: SizedBox(
                    width: chartWidth,
                    height: 320,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceBetween,
                              maxY: displayMaxValue * 1.15,
                              minY: 0,
                              groupsSpace: 18,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: interval,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.shade200,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= monthlyData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final item = monthlyData[index];
                                      final label =
                                          '${_getMonthName(item['month'] as int)} ${item['year']}';
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          label,
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
                                  left: BorderSide.none,
                                ),
                              ),
                              barTouchData: BarTouchData(
                                handleBuiltInTouches: false,
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipMargin: 4,
                                  tooltipPadding: EdgeInsets.zero,
                                  getTooltipColor: (group) =>
                                      Colors.transparent,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                        if (rod.toY <= 0) return null;
                                        return BarTooltipItem(
                                          _formatMillion(rod.toY.toInt()),
                                          TextStyle(
                                            color: rod.color,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        );
                                      },
                                ),
                              ),
                              barGroups: List.generate(monthlyData.length, (
                                index,
                              ) {
                                final item = monthlyData[index];
                                return BarChartGroupData(
                                  x: index,
                                  barsSpace: 4,
                                  showingTooltipIndicators: [
                                    if ((item['income'] as int) > 0) 0,
                                    if ((item['expense'] as int) > 0) 1,
                                  ],
                                  barRods: [
                                    BarChartRodData(
                                      toY: (item['income'] as int).toDouble(),
                                      color: Colors.green.shade600,
                                      width: 28,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                            show: true,
                                            toY: displayMaxValue * 1.15,
                                            color: Colors.transparent,
                                          ),
                                    ),
                                    BarChartRodData(
                                      toY: (item['expense'] as int).toDouble(),
                                      color: Colors.red.shade600,
                                      width: 28,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                            show: true,
                                            toY: displayMaxValue * 1.15,
                                            color: Colors.transparent,
                                          ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
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

  String _formatMillion(int amount) {
    final valueInMillion = amount / 1000000.0;
    return '${valueInMillion.toStringAsFixed(2)}M';
  }
}

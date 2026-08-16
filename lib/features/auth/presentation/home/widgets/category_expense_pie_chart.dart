import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/month_picker_bottom_sheet.dart';
import '../../../../transactions/presentation/list/transaction_collection_page.dart';
import '../../../../transactions/presentation/viewmodel/transactions_viewmodel.dart';
import 'category_expense_list_item.dart';
import 'home_card_skeleton.dart';

class CategoryExpensePieChart extends StatelessWidget {
  const CategoryExpensePieChart({
    super.key,
    required this.transactionsViewModel,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final TransactionsViewModel transactionsViewModel;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;

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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: StreamBuilder<Map<String, int>>(
          stream: transactionsViewModel.watchCategoryExpensesByMonth(
            selectedMonth.year,
            selectedMonth.month,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const HomeCardSkeleton(
                type: HomeCardSkeletonType.category,
              );
            }

            final categoryExpenses = snapshot.data!;

            if (categoryExpenses.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
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

            final categories = categoryExpenses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
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
                _buildHeader(context),
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                ...List.generate(categoriesWithColors.length, (index) {
                  final category = categoriesWithColors[index];
                  final amount = category['amount'] as int;
                  final percentage = amount / total * 100;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == categoriesWithColors.length - 1 ? 0 : 8,
                    ),
                    child: CategoryExpenseListItem(
                      rank: index + 1,
                      name: category['name'] as String,
                      amountLabel: _formatVND(amount),
                      percentage: percentage,
                      color: category['color'] as Color,
                      onTap: () => _openCategoryTransactions(
                        context,
                        category['name'] as String,
                        category['color'] as Color,
                      ),
                    ),
                  );
                }),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Expense by Category',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(selectedMonth.year, selectedMonth.month - 1),
                ),
                icon: Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
              ),
              InkWell(
                onTap: () => _pickMonth(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_getMonthName(selectedMonth.month)} ${selectedMonth.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(selectedMonth.year, selectedMonth.month + 1),
                ),
                icon: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Colors.grey.shade700,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final picked = await showMonthPickerBottomSheet(
      context: context,
      initialMonth: selectedMonth,
    );
    if (picked != null) onMonthChanged(picked);
  }

  void _openCategoryTransactions(
    BuildContext context,
    String categoryName,
    Color categoryColor,
  ) {
    final startDate = DateTime(selectedMonth.year, selectedMonth.month);
    final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionCollectionPage(
          title: 'Category Transactions',
          categoryName: categoryName,
          categoryIcon: Icons.category_outlined,
          categoryColor: categoryColor,
          startDate: startDate,
          endDate: endDate,
          transactionsStream: transactionsViewModel
              .watchCategoryTransactionsByMonth(
                categoryName,
                selectedMonth.year,
                selectedMonth.month,
              ),
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

  String _formatVND(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formatted đ';
  }
}

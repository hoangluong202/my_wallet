import 'package:flutter/material.dart';

import '../../../../categories/domain/category.dart';
import '../../../../transactions/presentation/model/transaction_view_data.dart';
import '../../../../budget/presentation/model/budget_view_data.dart';
import 'home_card_skeleton.dart';

class MonthlySpendingComparisonCard extends StatelessWidget {
  const MonthlySpendingComparisonCard({
    super.key,
    required this.transactionsStream,
    required this.budgetsStream,
  });

  final Stream<List<TransactionViewData>> transactionsStream;
  final Stream<List<BudgetViewData>> budgetsStream;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: StreamBuilder<List<TransactionViewData>>(
          stream: transactionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const _CardLoadingState();
            }

            final comparison = _calculateComparison(snapshot.data!);
            final difference = comparison.current - comparison.previous;
            final isHigher = difference > 0;
            final isEqual = difference == 0;
            final comparisonColor = isEqual
                ? const Color(0xFF64748B)
                : isHigher
                ? const Color(0xFFDC2626)
                : const Color(0xFF16A34A);

            final trendIcon = isHigher
                ? Icons.arrow_upward_rounded
                : isEqual
                ? Icons.remove_rounded
                : Icons.arrow_downward_rounded;

            return StreamBuilder<List<BudgetViewData>>(
              stream: budgetsStream,
              builder: (context, budgetSnapshot) {
                if (!budgetSnapshot.hasData) {
                  return const _CardLoadingState();
                }

                final monthlyBudget = _calculateMonthlyBudget(
                  budgetSnapshot.data!,
                );
                final hasBudget = monthlyBudget > 0;
                final remaining = monthlyBudget - comparison.current;
                final isOverBudget = hasBudget && remaining < 0;
                final budgetStatusColor = !hasBudget
                    ? const Color(0xFF64748B)
                    : isOverBudget
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A);
                final budgetProgress = hasBudget
                    ? (comparison.current / monthlyBudget).clamp(0.0, 1.0)
                    : 0.0;
                final budgetPercentage = hasBudget
                    ? (comparison.current / monthlyBudget * 100).round()
                    : 0;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Spent this month',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _formatVND(comparison.current),
                                        style: const TextStyle(
                                          fontSize: 23,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF111827),
                                          height: 1.2,
                                        ),
                                      ),
                                      if (hasBudget)
                                        TextSpan(
                                          text:
                                              '  /  ${_formatVND(monthlyBudget)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF9CA3AF),
                                            height: 1.2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: comparisonColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    trendIcon,
                                    size: 15,
                                    color: comparisonColor,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _formatDifference(difference),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: comparisonColor,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'vs same time last month',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF9CA3AF),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (hasBudget) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: budgetProgress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            budgetStatusColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$budgetPercentage% used',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOverBudget
                                    ? Icons.warning_amber_rounded
                                    : Icons.savings_outlined,
                                size: 13,
                                color: budgetStatusColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${_formatVND(remaining.abs())} ${isOverBudget ? 'over' : 'remaining'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: budgetStatusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'No budget set for this month',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  int _calculateMonthlyBudget(List<BudgetViewData> budgets) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    final currentBudgets = budgets.where(
      (budget) =>
          budget.startDate.isBefore(lastDay) &&
          budget.endDate.isAfter(firstDay),
    );
    return currentBudgets.fold<int>(
      0,
      (sum, budget) => sum + budget.estimatedAmount,
    );
  }

  ({int current, int previous}) _calculateComparison(
    List<TransactionViewData> transactions,
  ) {
    final now = DateTime.now();
    final currentStart = DateTime(now.year, now.month);
    final currentEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final previousMonth = DateTime(now.year, now.month - 1);
    final previousLastDay = DateTime(now.year, now.month, 0).day;
    final comparisonDay = now.day > previousLastDay ? previousLastDay : now.day;
    final previousStart = DateTime(previousMonth.year, previousMonth.month);
    final previousEnd = DateTime(
      previousMonth.year,
      previousMonth.month,
      comparisonDay,
      23,
      59,
      59,
      999,
    );

    int spendingBetween(DateTime start, DateTime end) => transactions
        .where(
          (transaction) =>
              !transaction.transactionDate.isBefore(start) &&
              !transaction.transactionDate.isAfter(end) &&
              (transaction.category.type == CategoryType.expense ||
                  transaction.category.type == CategoryType.loan),
        )
        .fold(0, (sum, transaction) => sum + transaction.amount);

    return (
      current: spendingBetween(currentStart, currentEnd),
      previous: spendingBetween(previousStart, previousEnd),
    );
  }

  String _formatDifference(int difference) => difference == 0
      ? _formatVND(0)
      : '${difference > 0 ? '+' : '-'}${_formatVND(difference.abs())}';

  String _formatVND(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return '$formatted đ';
  }
}

class _CardLoadingState extends StatelessWidget {
  const _CardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const HomeCardSkeleton(type: HomeCardSkeletonType.spending);
  }
}

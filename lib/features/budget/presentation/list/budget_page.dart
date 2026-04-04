import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../form/add_budget_page.dart';
import '../detail/budget_detail_page.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late final BudgetViewModel _viewModel;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<BudgetViewModel>();
  }

  void _prevMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
  });

  /// Budgets whose date range overlaps with [_selectedMonth].
  List<BudgetViewData> _filterByMonth(List<BudgetViewData> all) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );
    return all
        .where(
          (b) => b.startDate.isBefore(lastDay) && b.endDate.isAfter(firstDay),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          _BudgetHeader(
            onAdd: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBudgetPage()),
            ),
          ),

          // List + monthly summary
          Expanded(
            child: StreamBuilder<List<BudgetViewData>>(
              stream: _viewModel.watchAllBudgets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ErrorView(error: snapshot.error);
                }

                final all = snapshot.data ?? [];
                final budgets = _filterByMonth(all);

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Monthly summary card ──────────────────────────────
                    _MonthlySummaryCard(
                      budgets: budgets,
                      selectedMonth: _selectedMonth,
                      onPrev: _prevMonth,
                      onNext: _nextMonth,
                    ),

                    // ── Budget list ───────────────────────────────────────
                    if (budgets.isEmpty)
                      const _EmptyState()
                    else
                      ...List.generate(budgets.length, (i) {
                        final budget = budgets[i];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            i == 0 ? 12 : 0,
                            16,
                            12,
                          ),
                          child: _BudgetCard(
                            budget: budget,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    BudgetDetailPage(budgetId: budget.id),
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly summary card ─────────────────────────────────────────────────────

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.budgets,
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
  });

  final List<BudgetViewData> budgets;
  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    final totalEstimated = budgets.fold<int>(
      0,
      (s, b) => s + b.estimatedAmount,
    );
    final totalSpent = budgets.fold<int>(0, (s, b) => s + b.spentAmount);
    final remaining = totalEstimated - totalSpent;
    final isOverAll = totalSpent > totalEstimated;
    final overallProgress = totalEstimated > 0
        ? (totalSpent / totalEstimated).clamp(0.0, 1.0)
        : 0.0;
    final overBudgetCount = budgets.where((b) => b.isOverBudget).length;
    final monthLabel =
        '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}';

    final gradientColors = isOverAll
        ? [Colors.red.shade700, Colors.red.shade500]
        : [Colors.green.shade700, Colors.green.shade500];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOverAll ? Colors.red : Colors.green).withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month navigator ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(icon: Icons.chevron_left, onTap: onPrev),
              Text(
                monthLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _NavButton(icon: Icons.chevron_right, onTap: onNext),
            ],
          ),

          const SizedBox(height: 18),

          // ── Budget count / over-budget badges ─────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _SummaryBadge(
                label:
                    '${budgets.length} budget${budgets.length != 1 ? 's' : ''}',
                icon: Icons.pie_chart_outline,
              ),
              if (overBudgetCount > 0)
                _SummaryBadge(
                  label: '$overBudgetCount over budget',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange.shade300.withOpacity(0.5),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Spent / Estimated ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Spent',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatVNDWithSymbol(totalSpent),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'of ${CurrencyFormatter.formatVNDWithSymbol(totalEstimated)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    budgets.isEmpty
                        ? '—'
                        : isOverAll
                        ? 'Over by ${CurrencyFormatter.formatVNDWithSymbol(-remaining)}'
                        : '${CurrencyFormatter.formatVNDWithSymbol(remaining)} left',
                    style: TextStyle(
                      color: isOverAll ? Colors.orange.shade200 : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Overall progress bar (only when budgets exist) ────────────
          if (budgets.isNotEmpty && totalEstimated > 0) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall spending',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(overallProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overallProgress,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.25),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],

          // ── No budgets hint ───────────────────────────────────────────
          if (budgets.isEmpty) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                'No budgets for this month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.label, required this.icon, this.color});
  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: Colors.white,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.pie_chart_outline,
                color: Colors.green.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Plan your spending',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.shade50,
                foregroundColor: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Budget card ─────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.onTap});
  final BudgetViewData budget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressColor = budget.isOverBudget
        ? Colors.red
        : Colors.green.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: budget.categoryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    budget.categoryIcon,
                    color: budget.categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.categoryName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${DateFormatter.formatDate(budget.startDate)} – ${DateFormatter.formatDate(budget.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatVNDWithSymbol(budget.spentAmount),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      '/ ${CurrencyFormatter.formatVNDWithSymbol(budget.estimatedAmount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Money progress bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Spending',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(budget.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budget.progress,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progressColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Days progress bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            budget.isExpired
                                ? 'Expired'
                                : budget.isNotStarted
                                ? '${budget.totalDays}d total'
                                : '${budget.daysRemaining}d left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: budget.isExpired
                                  ? Colors.orange.shade700
                                  : Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: budget.dayProgress,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            budget.isExpired
                                ? Colors.orange.shade400
                                : Colors.blue.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Bottom label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  budget.isOverBudget ? 'Over budget' : 'On track',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: progressColor,
                  ),
                ),
                Text(
                  budget.isOverBudget
                      ? 'Over by ${CurrencyFormatter.formatVNDWithSymbol(-budget.remainingAmount)}'
                      : '${CurrencyFormatter.formatVNDWithSymbol(budget.remainingAmount)} left',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart_outline,
              size: 56,
              color: Colors.green.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first budget.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

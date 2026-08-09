import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../form/add_budget_page.dart';
import '../detail/budget_detail_page.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';
import 'widgets/budget_card.dart';
import 'widgets/budget_empty_state.dart';
import 'widgets/budget_error_view.dart';
import 'widgets/budget_header.dart';
import 'widgets/monthly_summary_card.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: Column(
        children: [
          // Header
          BudgetHeader(
            selectedMonth: _selectedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
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
                  return BudgetErrorView(error: snapshot.error);
                }

                final all = snapshot.data ?? [];
                final budgets = _filterByMonth(all);

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // ── Monthly summary card ──────────────────────────────
                    MonthlySummaryCard(budgets: budgets),

                    // ── Budget list ───────────────────────────────────────
                    if (budgets.isEmpty)
                      const BudgetEmptyState()
                    else
                      ...List.generate(budgets.length, (i) {
                        final budget = budgets[i];
                        return Padding(
                          padding: EdgeInsets.fromLTRB(8, i == 0 ? 8 : 0, 8, 8),
                          child: BudgetCard(
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

                    const SizedBox(height: 8),
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

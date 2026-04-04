import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../form/add_budget_page.dart';
import '../detail/budget_detail_page.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getIt<BudgetViewModel>();

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

          // List
          Expanded(
            child: StreamBuilder<List<BudgetViewData>>(
              stream: viewModel.watchAllBudgets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _ErrorView(error: snapshot.error);
                }

                final budgets = snapshot.data ?? [];

                if (budgets.isEmpty) {
                  return const _EmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: budgets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _BudgetCard(
                      budget: budgets[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BudgetDetailPage(budgetId: budgets[index].id),
                        ),
                      ),
                    );
                  },
                );
              },
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

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 8),

            // Usage label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(budget.progress * 100).toStringAsFixed(0)}% used',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../form/edit_budget_page.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';

class BudgetDetailPage extends StatefulWidget {
  final String budgetId;

  const BudgetDetailPage({super.key, required this.budgetId});

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  late final BudgetViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<BudgetViewModel>();
  }

  Future<void> _confirmDelete(BudgetViewData budget) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Budget',
      content:
          'Delete the budget for "${budget.categoryName}"? This cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
      icon: Icons.delete_outline,
    );
    if (confirmed != true || !mounted) return;

    final success = await _viewModel.deleteBudget(budget.id);
    if (!mounted) return;

    if (success) {
      SuccessNotification.show(
        context: context,
        message: 'Budget deleted successfully',
      );
      Navigator.pop(context, true);
    } else {
      ErrorNotification.show(
        context: context,
        message: _viewModel.errorMessage ?? 'Failed to delete budget',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BudgetViewData?>(
      stream: _viewModel.watchBudgetById(widget.budgetId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text(
                snapshot.hasError ? 'Error: ${snapshot.error}' : 'Not found',
              ),
            ),
          );
        }

        final budget = snapshot.data!;
        return _buildPage(budget);
      },
    );
  }

  Widget _buildPage(BudgetViewData budget) {
    final progressColor = budget.isOverBudget
        ? Colors.red
        : Colors.green.shade600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _DetailHeader(
              budget: budget,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditBudgetPage(budget: budget),
                ),
              ),
              onDelete: () => _confirmDelete(budget),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Progress card
                    _ProgressCard(budget: budget, progressColor: progressColor),
                    const SizedBox(height: 12),
                    // Info card
                    _InfoCard(budget: budget),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetViewData budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Budget Detail',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

// ─── Progress card ────────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.budget, required this.progressColor});

  final BudgetViewData budget;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        children: [
          // Category icon + name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: budget.categoryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  budget.categoryIcon,
                  color: budget.categoryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      budget.categoryType.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              if (budget.isOverBudget)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Over budget',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Money progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(budget.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget.progress,
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 16),

          // Days progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 12,
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
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: budget.isExpired
                      ? Colors.orange.shade700
                      : Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: budget.dayProgress,
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.isExpired
                    ? Colors.orange.shade400
                    : Colors.blue.shade400,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Amounts row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountTile(
                label: 'Spent',
                amount: budget.spentAmount,
                color: progressColor,
              ),
              _AmountTile(
                label: 'Remaining',
                amount: budget.remainingAmount.abs(),
                color: budget.isOverBudget ? Colors.red : Colors.grey.shade700,
                prefix: budget.isOverBudget ? '-' : '',
              ),
              _AmountTile(
                label: 'Budget',
                amount: budget.estimatedAmount,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AmountTile extends StatelessWidget {
  const _AmountTile({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  final String label;
  final int amount;
  final Color color;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          '$prefix${CurrencyFormatter.formatVNDWithSymbol(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.budget});
  final BudgetViewData budget;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Start date',
            value: DateFormatter.formatDate(budget.startDate),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.event_outlined,
            label: 'End date',
            value: DateFormatter.formatDate(budget.endDate),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.percent,
            label: 'Progress',
            value: '${(budget.progress * 100).toStringAsFixed(1)}%',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.update_outlined,
            label: 'Last updated',
            value: DateFormatter.formatDate(budget.updatedAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/presentation/detail/transaction_details_page.dart';
import '../../../transactions/presentation/list/transaction_item_card.dart';
import '../../../transactions/presentation/model/transaction_view_data.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';

class BudgetTransactionsPage extends StatefulWidget {
  final BudgetViewData budget;

  const BudgetTransactionsPage({super.key, required this.budget});

  @override
  State<BudgetTransactionsPage> createState() => _BudgetTransactionsPageState();
}

class _BudgetTransactionsPageState extends State<BudgetTransactionsPage> {
  late final BudgetViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<BudgetViewModel>();
  }

  void _onTransactionTap(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsPage(transactionId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budget = widget.budget;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _TransactionsHeader(budget: budget),

            // Body
            Expanded(
              child: StreamBuilder<List<TransactionViewData>>(
                stream: _viewModel.watchBudgetTransactions(budget),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return _EmptyState(budget: budget);
                  }

                  // Group by date
                  final grouped = _groupByDate(transactions);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final entry = grouped.entries.elementAt(index);
                      final date = entry.key;
                      final items = entry.value;
                      return _DateGroup(
                        date: date,
                        transactions: items,
                        onTap: _onTransactionTap,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<DateTime, List<TransactionViewData>> _groupByDate(
    List<TransactionViewData> transactions,
  ) {
    final sorted = [...transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final Map<DateTime, List<TransactionViewData>> grouped = {};
    for (final t in sorted) {
      final day = DateTime(
        t.transactionDate.year,
        t.transactionDate.month,
        t.transactionDate.day,
      );
      grouped.putIfAbsent(day, () => []).add(t);
    }
    return grouped;
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _TransactionsHeader extends StatelessWidget {
  final BudgetViewData budget;

  const _TransactionsHeader({required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Budget Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Budget summary chip row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Category badge — flexible so a long name doesn't overflow
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: budget.categoryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          budget.categoryIcon,
                          size: 14,
                          color: budget.categoryColor,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            budget.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: budget.categoryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Date range badge — shrink-wraps, never truncated
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormatter.formatDateRange(
                        budget.startDate,
                        budget.endDate,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date group ───────────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<TransactionViewData> transactions;
  final ValueChanged<String> onTap;

  const _DateGroup({
    required this.date,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayTotal = transactions.fold<int>(0, (sum, t) => sum + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatDate(date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                CurrencyFormatter.formatVNDWithSymbol(dayTotal),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        // Transaction cards
        ...transactions.map(
          (t) => TransactionItemCard(transaction: t, onTap: () => onTap(t.id)),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final BudgetViewData budget;

  const _EmptyState({required this.budget});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found for "${budget.categoryName}" between\n'
              '${DateFormatter.formatDate(budget.startDate)} and ${DateFormatter.formatDate(budget.endDate)}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

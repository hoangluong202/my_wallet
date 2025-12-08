import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../data/models/transaction_item.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../pages/transaction_details_page.dart';
import 'transaction_summary_item.dart';
import 'transaction_item_card.dart';

enum TabType { past, today, future }

class TransactionsTabContent extends StatelessWidget {
  final TabType tabType;
  final List<Transaction> transactions;
  final Map<String, Category> categoriesCache;
  final Map<String, Wallet> walletsCache;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback?
  onTransactionChanged; // Add callback for when transaction is edited/deleted

  const TransactionsTabContent({
    super.key,
    required this.tabType,
    required this.transactions,
    required this.categoriesCache,
    required this.walletsCache,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    this.onTransactionChanged, // Optional callback
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final transactionsByDate = _getGroupedTransactions(tabType, transactions);

    if (transactionsByDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade100,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 56,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No transactions found for this period',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: transactionsByDate.length,
      itemBuilder: (context, index) {
        final entry = transactionsByDate.entries.elementAt(index);
        final dateGroup = entry.key;
        final transactions = entry.value;

        // Calculate totals for this date group
        // Increased: Income + Debt
        // Decreased: Expense + Loan
        double totalIncreased = 0;
        double totalDecreased = 0;

        for (final transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            totalIncreased += transaction.amount;
          } else if (transaction.type == TransactionType.debt) {
            totalIncreased += transaction.amount;
          } else if (transaction.type == TransactionType.expense) {
            totalDecreased += transaction.amount;
          } else if (transaction.type == TransactionType.loan) {
            totalDecreased += transaction.amount;
          }
        }

        final netDifference = totalIncreased - totalDecreased;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Group Header
            _buildDateGroupHeader(
              context,
              dateGroup,
              totalIncreased,
              totalDecreased,
              netDifference,
            ),
            const SizedBox(height: 12),

            // Transaction Items
            ...transactions.map((transaction) {
              return TransactionItemCard(
                transaction: transaction,
                onTap: () => _onTransactionTap(context, transaction),
              );
            }).toList(),

            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildDateGroupHeader(
    BuildContext context,
    String dateGroup,
    double totalIncreased,
    double totalDecreased,
    double netDifference,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateGroup,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: netDifference >= 0
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${netDifference >= 0 ? '+' : ''}${CurrencyFormatter.formatVNDWithSymbol(netDifference)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: netDifference >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TransactionSummaryItem(
                icon: Icons.trending_up,
                label: 'Increased',
                amount: totalIncreased,
                color: Colors.green,
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              TransactionSummaryItem(
                icon: Icons.trending_down,
                label: 'Decreased',
                amount: totalDecreased,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTransactionTap(
    BuildContext context,
    TransactionItem transaction,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailsPage(initialTransaction: transaction),
      ),
    );

    // If transaction was edited or deleted, trigger reload via callback
    if (result == true) {
      onTransactionChanged?.call();
    }
  }

  Map<String, List<TransactionItem>> _getGroupedTransactions(
    TabType tabType,
    List<Transaction> transactions,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter transactions based on tab type
    final filteredTransactions = transactions.where((transaction) {
      final transactionDate = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      switch (tabType) {
        case TabType.past:
          return transactionDate.isBefore(today);
        case TabType.today:
          return transactionDate.isAtSameMomentAs(today);
        case TabType.future:
          return transactionDate.isAfter(today);
      }
    }).toList();

    // Group filtered transactions by date
    final grouped = <String, List<TransactionItem>>{};

    for (final transaction in filteredTransactions) {
      final dateLabel = _getDateLabel(transaction.transactionDate);
      if (!grouped.containsKey(dateLabel)) {
        grouped[dateLabel] = [];
      }

      // Get category details
      final category = categoriesCache[transaction.categoryId];
      final categoryName = category?.name ?? 'Unknown Category';
      final categoryIcon = category?.icon ?? Icons.category;
      final categoryType = category?.type.name ?? 'expense';

      // Get wallet details
      final wallet = walletsCache[transaction.walletId];
      final walletName = wallet?.name ?? 'Unknown Wallet';

      // Determine transaction type from category
      final transactionType = switch (categoryType) {
        'income' => TransactionType.income,
        'expense' => TransactionType.expense,
        'debt' => TransactionType.debt,
        'loan' => TransactionType.loan,
        _ => TransactionType.expense,
      };

      // Convert Transaction to TransactionItem for UI
      grouped[dateLabel]!.add(
        TransactionItem(
          id: transaction.id,
          description: transaction.note?.isNotEmpty == true
              ? transaction.note!
              : walletName,
          category: categoryName,
          amount: transaction.amount,
          type: transactionType,
          categoryIcon: categoryIcon,
          date: transaction.transactionDate,
          walletName: walletName,
        ),
      );
    }

    return grouped;
  }

  /// Format date as readable label
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      // Format as "Nov 10, 2025"
      const months = [
        '',
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
      return '${months[date.month]} ${date.day}, ${date.year}';
    }
  }
}

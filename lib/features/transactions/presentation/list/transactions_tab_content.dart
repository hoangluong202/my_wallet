import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../model/transaction_view_data.dart';
import '../detail/transaction_details_page.dart';
import 'transaction_summary_item.dart';
import 'transaction_item_card.dart';
import '../../../categories/domain/category.dart';

enum TabType { past, today, future }

class TransactionsTabContent extends StatelessWidget {
  final TabType tabType;
  final List<TransactionViewData> transactions;

  const TransactionsTabContent({
    super.key,
    required this.tabType,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final filteredList = _filterAndGroupTransactions(transactions, tabType);

    if (filteredList.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemBuilder: (context, index) {
        final entry = filteredList.entries.elementAt(index);
        final dateGroup = entry.key;
        final transactions = entry.value;

        int totalIncreased = 0;
        int totalDecreased = 0;

        for (final transaction in transactions) {
          if (transaction.category.type == CategoryType.income) {
            totalIncreased += transaction.amount;
          } else if (transaction.category.type == CategoryType.debt) {
            totalIncreased += transaction.amount;
          } else if (transaction.category.type == CategoryType.expense) {
            totalDecreased += transaction.amount;
          } else if (transaction.category.type == CategoryType.loan) {
            totalDecreased += transaction.amount;
          }
        }

        final netDifference = totalIncreased - totalDecreased;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    DateTime dateGroup,
    int totalIncreased,
    int totalDecreased,
    int netDifference,
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
                _getDateLabel(dateGroup),
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
    TransactionViewData transaction,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TransactionDetailsPage(transactionId: transaction.id),
      ),
    );
  }

  Map<DateTime, List<TransactionViewData>> _filterAndGroupTransactions(
    List<TransactionViewData> list,
    TabType type,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered = list.where((tx) {
      final txDate = DateTime(
        tx.transactionDate.year,
        tx.transactionDate.month,
        tx.transactionDate.day,
      );

      if (type == TabType.past) return txDate.isBefore(today);
      if (type == TabType.today) return txDate.isAtSameMomentAs(today);
      return txDate.isAfter(today);
    }).toList();

    filtered.sort((a, b) {
      if (type == TabType.future) {
        return a.transactionDate.compareTo(b.transactionDate);
      }
      return b.transactionDate.compareTo(a.transactionDate);
    });

    final Map<DateTime, List<TransactionViewData>> grouped = {};
    for (var tx in filtered) {
      final dateKey = DateTime(
        tx.transactionDate.year,
        tx.transactionDate.month,
        tx.transactionDate.day,
      );

      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(tx);
    }

    return grouped;
  }

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

  Widget _buildEmptyState(BuildContext context) {
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
}

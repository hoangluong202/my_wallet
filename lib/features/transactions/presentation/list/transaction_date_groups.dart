import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../model/transaction_view_data.dart';
import 'transaction_item_card.dart';

class TransactionDateGroups extends StatelessWidget {
  const TransactionDateGroups({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  final List<TransactionViewData> transactions;
  final ValueChanged<TransactionViewData> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(transactions);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in grouped.entries)
          _TransactionDateGroup(
            date: entry.key,
            transactions: entry.value,
            onTransactionTap: onTransactionTap,
          ),
      ],
    );
  }

  Map<DateTime, List<TransactionViewData>> _groupByDate(
    List<TransactionViewData> transactions,
  ) {
    final sorted = [...transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    final grouped = <DateTime, List<TransactionViewData>>{};
    for (final transaction in sorted) {
      final date = DateUtils.dateOnly(transaction.transactionDate);
      grouped.putIfAbsent(date, () => []).add(transaction);
    }
    return grouped;
  }
}

class _TransactionDateGroup extends StatelessWidget {
  const _TransactionDateGroup({
    required this.date,
    required this.transactions,
    required this.onTransactionTap,
  });

  final DateTime date;
  final List<TransactionViewData> transactions;
  final ValueChanged<TransactionViewData> onTransactionTap;

  @override
  Widget build(BuildContext context) {
    final total = transactions.fold<int>(0, (sum, item) => sum + item.amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormatter.formatDate(date)),
              Text(CurrencyFormatter.formatVNDWithSymbol(total)),
            ],
          ),
        ),
        for (final transaction in transactions)
          TransactionItemCard(
            transaction: transaction,
            onTap: () => onTransactionTap(transaction),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

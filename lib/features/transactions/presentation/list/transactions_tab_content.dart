import 'package:flutter/material.dart';
import '../model/transaction_view_data.dart';
import '../detail/transaction_details_page.dart';
import 'transaction_item_card.dart';
import '../../../categories/domain/category.dart';
import 'transaction_summary_card.dart';

class _GroupedDateData {
  final DateTime date;
  final List<TransactionViewData> transactions;
  final int totalIncreased;
  final int totalDecreased;
  final int netDifference;

  _GroupedDateData({
    required this.date,
    required this.transactions,
    required this.totalIncreased,
    required this.totalDecreased,
    required this.netDifference,
  });
}

class TransactionsTabContent extends StatefulWidget {
  final List<TransactionViewData> transactions;
  final bool isFuture;
  final bool showSummary;

  const TransactionsTabContent({
    super.key,
    required this.transactions,
    this.isFuture = false,
    this.showSummary = true,
  });

  @override
  State<TransactionsTabContent> createState() => _TransactionsTabContentState();
}

class _TransactionsTabContentState extends State<TransactionsTabContent>
    with AutomaticKeepAliveClientMixin {
  List<_GroupedDateData> _processedData = [];
  int _totalIncome = 0;
  int _totalExpense = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _groupAndCalculateData();
  }

  @override
  void didUpdateWidget(covariant TransactionsTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.isFuture != widget.isFuture) {
      _groupAndCalculateData();
    }
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

  void _groupAndCalculateData() {
    final sortedList = List<TransactionViewData>.from(widget.transactions);

    sortedList.sort((a, b) {
      if (widget.isFuture) {
        return a.transactionDate.compareTo(b.transactionDate);
      }
      return b.transactionDate.compareTo(a.transactionDate);
    });

    final Map<DateTime, List<TransactionViewData>> groupedMap = {};
    int income = 0;
    int expense = 0;

    for (var tx in sortedList) {
      final dateKey = DateTime(
        tx.transactionDate.year,
        tx.transactionDate.month,
        tx.transactionDate.day,
      );

      groupedMap.putIfAbsent(dateKey, () => []).add(tx);

      switch (tx.category.type) {
        case CategoryType.income:
        case CategoryType.debt:
          income += tx.amount;
          break;
        case CategoryType.expense:
        case CategoryType.loan:
          expense += tx.amount;
          break;
      }
    }

    final List<_GroupedDateData> tempData = [];

    for (var entry in groupedMap.entries) {
      int totalIncreased = 0;
      int totalDecreased = 0;

      for (final tx in entry.value) {
        switch (tx.category.type) {
          case CategoryType.income:
          case CategoryType.debt:
            totalIncreased += tx.amount;
            break;
          case CategoryType.expense:
          case CategoryType.loan:
            totalDecreased += tx.amount;
            break;
        }
      }

      tempData.add(
        _GroupedDateData(
          date: entry.key,
          transactions: entry.value,
          totalIncreased: totalIncreased,
          totalDecreased: totalDecreased,
          netDifference: totalIncreased - totalDecreased,
        ),
      );
    }

    setState(() {
      _processedData = tempData;
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_processedData.isEmpty) {
      return _buildEmptyState();
    }

    final hasSummary = widget.showSummary;
    final itemCount = _processedData.length + (hasSummary ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Sử dụng Widget Custom mới tại đây
        if (hasSummary && index == 0) {
          return TransactionsSummaryCard(
            totalIncome: _totalIncome,
            totalExpense: _totalExpense,
          );
        }

        final dataIndex = hasSummary ? index - 1 : index;
        final group = _processedData[dataIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.transactions.length,
              itemBuilder: (context, txIndex) {
                final transaction = group.transactions[txIndex];
                return TransactionItemCard(
                  transaction: transaction,
                  onTap: () => _onTransactionTap(context, transaction),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
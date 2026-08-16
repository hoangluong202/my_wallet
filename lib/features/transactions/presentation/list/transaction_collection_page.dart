import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../detail/transaction_details_page.dart';
import '../model/transaction_view_data.dart';
import 'transaction_date_groups.dart';

class TransactionCollectionPage extends StatelessWidget {
  const TransactionCollectionPage({
    super.key,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.startDate,
    required this.endDate,
    required this.transactionsStream,
  });

  final String title;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final DateTime startDate;
  final DateTime endDate;
  final Stream<List<TransactionViewData>> transactionsStream;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: title,
              categoryName: categoryName,
              categoryIcon: categoryIcon,
              categoryColor: categoryColor,
              startDate: startDate,
              endDate: endDate,
            ),
            Expanded(
              child: StreamBuilder<List<TransactionViewData>>(
                stream: transactionsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final transactions = snapshot.data!;
                  if (transactions.isEmpty) {
                    return _EmptyState(
                      categoryName: categoryName,
                      startDate: startDate,
                      endDate: endDate,
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    children: [
                      TransactionDateGroups(
                        transactions: transactions,
                        onTransactionTap: (transaction) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionDetailsPage(
                              transactionId: transaction.id,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.startDate,
    required this.endDate,
  });

  final String title;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(8, 4, 24, 16),
    child: Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Flexible(
                child: _CategoryChip(
                  name: categoryName,
                  icon: categoryIcon,
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _InfoChip(
                  label: DateFormatter.formatDateRange(startDate, endDate),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.categoryName,
    required this.startDate,
    required this.endDate,
  });
  final String categoryName;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Widget build(BuildContext context) => Center(
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
            'No transactions found for "$categoryName" between\n'
            '${DateFormatter.formatDate(startDate)} and '
            '${DateFormatter.formatDate(endDate)}.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    ),
  );
}

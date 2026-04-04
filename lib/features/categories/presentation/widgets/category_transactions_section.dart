import 'package:flutter/material.dart';

import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../domain/category.dart';
import '../constants/category_icons.dart';
import '../model/category_view_data.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'category_type_badge.dart';

class CategoryTransactionsSection extends StatelessWidget {
  final CategoryViewData category;
  final TransactionRepository transactionRepository;
  final ValueChanged<String> onTransactionTap;

  const CategoryTransactionsSection({
    super.key,
    required this.category,
    required this.transactionRepository,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _TransactionsHeaderWithTotal(
          categoryId: category.id,
          repository: transactionRepository,
        ),
        const SizedBox(height: 12),
        _TransactionList(
          categoryId: category.id,
          repository: transactionRepository,
          onTap: onTransactionTap,
        ),
      ],
    );
  }
}

class _TransactionsHeaderWithTotal extends StatelessWidget {
  final String categoryId;
  final TransactionRepository repository;

  const _TransactionsHeaderWithTotal({
    required this.categoryId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: repository.watchTransactionsByCategory(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Text(
                'Transactions This Month',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 60,
                height: 16,
                child: LinearProgressIndicator(),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Transactions This Month',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          );
        }
        final transactions = _TransactionList._filterCurrentMonthStatic(
          snapshot.data ?? [],
        );
        final int total = transactions.fold<int>(
          0,
          (sum, t) => sum + ((t.amount ?? 0) as int),
        );
        return Row(
          children: [
            Text(
              'Transactions This Month',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container()),
            Text(
              CurrencyFormatter.formatVNDWithSymbol(total),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TransactionList extends StatelessWidget {
  final String categoryId;
  final TransactionRepository repository;
  final ValueChanged<String> onTap;

  const _TransactionList({
    required this.categoryId,
    required this.repository,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: repository.watchTransactionsByCategory(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: [${snapshot.error}'),
          );
        }

        final transactions = _filterCurrentMonth(snapshot.data ?? []);

        if (transactions.isEmpty) {
          return _EmptyTransactions();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: transactions.length,
          itemBuilder: (_, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TransactionItem(
              transaction: transactions[index],
              onTap: () => onTap(transactions[index].id),
            ),
          ),
        );
      },
    );
  }

  static List<dynamic> _filterCurrentMonthStatic(List<dynamic> transactions) {
    final now = DateTime.now();
    return transactions
        .where(
          (t) =>
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month,
        )
        .toList();
  }

  List<dynamic> _filterCurrentMonth(List<dynamic> transactions) {
    return _filterCurrentMonthStatic(transactions);
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'No transactions this month',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final dynamic transaction;
  final VoidCallback onTap;

  const _TransactionItem({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = CategoryIcons.getIconByCodePoint(
      transaction.category.iconCode,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _TransactionIcon(color: iconData.color, icon: iconData.icon),
            const SizedBox(width: 12),
            Expanded(child: _TransactionInfo(transaction: transaction)),
            _TransactionAmount(transaction: transaction),
          ],
        ),
      ),
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _TransactionIcon({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _TransactionInfo extends StatelessWidget {
  final dynamic transaction;

  const _TransactionInfo({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.category.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          transaction.note ?? transaction.wallet.name,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _TransactionAmount extends StatelessWidget {
  final dynamic transaction;

  const _TransactionAmount({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = (transaction.category.type as CategoryType).isCredit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isCredit ? '+' : '-'}${CurrencyFormatter.formatVNDWithSymbol(transaction.amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        Text(
          '${transaction.transactionDate.day}/${transaction.transactionDate.month}',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

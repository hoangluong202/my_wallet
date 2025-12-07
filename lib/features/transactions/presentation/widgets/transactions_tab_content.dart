import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/transaction.dart';
import '../../data/models/transaction_item.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../wallets/presentation/viewmodels/wallets_viewmodel.dart';
import '../../../wallets/domain/entities/wallet.dart';
import '../pages/transaction_details_page.dart';
import 'transaction_summary_item.dart';
import 'transaction_item_card.dart';

enum TabType { past, today, future }

class TransactionsTabContent extends StatefulWidget {
  final TabType tabType;
  final TransactionsViewModel viewModel;

  const TransactionsTabContent({
    super.key,
    required this.tabType,
    required this.viewModel,
  });

  @override
  State<TransactionsTabContent> createState() => _TransactionsTabContentState();
}

class _TransactionsTabContentState extends State<TransactionsTabContent> {
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;
  Map<String, Category> _categoriesCache = {};
  Map<String, Wallet> _walletsCache = {};

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();
    _loadData();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    // Load transactions
    await widget.viewModel.loadTransactions();

    // Load categories and wallets for display
    await _loadCategoriesAndWallets();
  }

  Future<void> _loadCategoriesAndWallets() async {
    // Load categories
    await _categoriesViewModel.loadCategories();
    _categoriesCache = {
      for (var cat in _categoriesViewModel.categories) cat.id: cat,
    };

    // Load wallets
    await _walletsViewModel.loadWallets();
    _walletsCache = {
      for (var wallet in _walletsViewModel.wallets) wallet.id: wallet,
    };

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.error != null) {
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
              widget.viewModel.error!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => widget.viewModel.loadTransactions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final transactionsByDate = _getGroupedTransactions(
      widget.tabType,
      widget.viewModel.transactions,
    );

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
        double totalIncome = 0;
        double totalExpense = 0;

        for (final transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            totalIncome += transaction.amount;
          } else {
            totalExpense += transaction.amount;
          }
        }

        final netDifference = totalIncome - totalExpense;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Group Header
            _buildDateGroupHeader(
              context,
              dateGroup,
              totalIncome,
              totalExpense,
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
    double totalIncome,
    double totalExpense,
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
                label: 'Income',
                amount: totalIncome,
                color: Colors.green,
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              TransactionSummaryItem(
                icon: Icons.trending_down,
                label: 'Expense',
                amount: totalExpense,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onTransactionTap(BuildContext context, TransactionItem transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailsPage(transaction: transaction),
      ),
    );
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
      final category = _categoriesCache[transaction.categoryId];
      final categoryName = category?.name ?? 'Unknown Category';
      final categoryIcon = category?.icon ?? Icons.category;
      final categoryType = category?.type.name ?? 'expense';

      // Get wallet details
      final wallet = _walletsCache[transaction.walletId];
      final walletName = wallet?.name ?? 'Unknown Wallet';

      // Determine transaction type from category
      final transactionType = categoryType == 'income'
          ? TransactionType.income
          : TransactionType.expense;

      // Convert Transaction to TransactionItem for UI
      grouped[dateLabel]!.add(
        TransactionItem(
          description: transaction.note?.isNotEmpty == true
              ? transaction.note!
              : walletName,
          category: categoryName,
          amount: transaction.amount,
          type: transactionType,
          categoryIcon: categoryIcon,
          date: transaction.transactionDate,
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

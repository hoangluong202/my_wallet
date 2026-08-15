import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injector.dart';
import 'transactions_tab_content.dart';
import '../model/transaction_view_data.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late final TransactionsViewModel _viewModel;
  late final WalletsViewModel _walletsViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<TransactionsViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();
  }

  List<DateTime> _getPastMonthsAscending(
    List<TransactionViewData> allTransactions,
  ) {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);

    final pastMonthsSet = allTransactions
        .map(
          (tx) =>
              DateTime(tx.transactionDate.year, tx.transactionDate.month, 1),
        )
        .where((date) => date.isBefore(thisMonthStart))
        .toSet()
        .toList();

    pastMonthsSet.sort((a, b) => a.compareTo(b));

    if (pastMonthsSet.isEmpty) {
      pastMonthsSet.add(DateTime(now.year, now.month - 1, 1));
    }

    return pastMonthsSet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<TransactionViewData>>(
        stream: _viewModel.watchAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allTransactions = snapshot.data ?? [];
          final now = DateTime.now();
          final thisMonthStart = DateTime(now.year, now.month, 1);
          final nextMonthStart = DateTime(now.year, now.month + 1, 1);

          final pastMonths = _getPastMonthsAscending(allTransactions);

          final List<String> tabTitles = [];
          final List<List<TransactionViewData>> tabData = [];

          // Past Months
          for (var monthDate in pastMonths) {
            tabTitles.add(DateFormat('MM/yyyy').format(monthDate));
            final filteredPast = allTransactions.where((tx) {
              return tx.transactionDate.year == monthDate.year &&
                  tx.transactionDate.month == monthDate.month;
            }).toList();
            tabData.add(filteredPast);
          }

          // This Month
          tabTitles.add('This Month');
          final thisMonthIndex = tabTitles.length - 1;
          final filteredThisMonth = allTransactions.where((tx) {
            final date = tx.transactionDate;
            return (date.isAtSameMomentAs(thisMonthStart) ||
                    date.isAfter(thisMonthStart)) &&
                date.isBefore(nextMonthStart);
          }).toList();
          tabData.add(filteredThisMonth);

          // Future
          tabTitles.add('Future');
          final filteredFuture = allTransactions.where((tx) {
            return tx.transactionDate.isAtSameMomentAs(nextMonthStart) ||
                tx.transactionDate.isAfter(nextMonthStart);
          }).toList();
          tabData.add(filteredFuture);

          return DefaultTabController(
            // Dùng một ObjectKey dựa trên độ dài titles để tránh lỗi rebuild sai index
            key: ObjectKey(tabTitles.length),
            length: tabTitles.length,
            initialIndex: thisMonthIndex,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: TabBar(
                    isScrollable: tabTitles.length > 3,
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Colors.grey.shade500,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: tabTitles.map((title) => Tab(text: title)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: List.generate(tabTitles.length, (index) {
                      // Fix: set isFuture chính xác cho tab Future ở vị trí cuối cùng
                      final isFutureTab = index == tabTitles.length - 1;
                      return TransactionsTabContent(
                        key: ValueKey('${tabTitles[index]}_$index'),
                        transactions: tabData[index],
                        walletsStream: _walletsViewModel.walletsStream,
                        isFuture: isFutureTab,
                        // Ẩn summary card nếu là tab Future theo logic của bạn
                        showSummary: !isFutureTab,
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

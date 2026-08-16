import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../transactions/presentation/list/transaction_collection_page.dart';
import '../model/budget_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';

class BudgetTransactionsPage extends StatelessWidget {
  const BudgetTransactionsPage({super.key, required this.budget});

  final BudgetViewData budget;

  @override
  Widget build(BuildContext context) {
    return TransactionCollectionPage(
      title: 'Budget Transactions',
      categoryName: budget.categoryName,
      categoryIcon: budget.categoryIcon,
      categoryColor: budget.categoryColor,
      startDate: budget.startDate,
      endDate: budget.endDate,
      transactionsStream: getIt<BudgetViewModel>().watchBudgetTransactions(
        budget,
      ),
    );
  }
}

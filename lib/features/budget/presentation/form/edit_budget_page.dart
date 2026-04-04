import 'package:flutter/material.dart';
import '../model/budget_view_data.dart';
import 'add_budget_page.dart';

/// Thin wrapper that opens [AddBudgetPage] in edit mode, pre-populating all
/// fields from the existing [budget].
class EditBudgetPage extends StatelessWidget {
  final BudgetViewData budget;

  const EditBudgetPage({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    return AddBudgetPage(
      budgetId: budget.id,
      initialCategoryId: budget.categoryId,
      initialEstimatedAmount: budget.estimatedAmount,
      initialStartDate: budget.startDate,
      initialEndDate: budget.endDate,
    );
  }
}

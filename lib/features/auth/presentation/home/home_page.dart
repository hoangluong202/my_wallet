import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../budget/presentation/viewmodel/budget_viewmodel.dart';
import '../../../transactions/presentation/viewmodel/transactions_viewmodel.dart';
import 'widgets/category_expense_pie_chart.dart';
import 'widgets/daily_income_expense_chart.dart';
import 'widgets/monthly_spending_comparison_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TransactionsViewModel _transactionsViewModel;

  // Selected month for category chart
  DateTime _selectedPieChartMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _transactionsViewModel = getIt<TransactionsViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            MonthlySpendingComparisonCard(
              transactionsStream: _transactionsViewModel.watchAllTransactions(),
              budgetsStream: getIt<BudgetViewModel>().watchBudgetDefinitions(),
            ),
            const SizedBox(height: 12),
            _buildIncomeExpenseChart(context),
            const SizedBox(height: 12),
            _buildCategoryPieChart(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(BuildContext context) {
    return DailyIncomeExpenseChart(
      transactionsViewModel: _transactionsViewModel,
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    return CategoryExpensePieChart(
      transactionsViewModel: _transactionsViewModel,
      selectedMonth: _selectedPieChartMonth,
      onMonthChanged: (month) {
        setState(() {
          _selectedPieChartMonth = month;
        });
      },
    );
  }
}

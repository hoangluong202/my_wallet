import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/auth/presentation/home/widgets/monthly_spending_comparison_card.dart';
import 'package:my_wallet/features/auth/presentation/home/widgets/home_card_skeleton.dart';
import 'package:my_wallet/features/budget/presentation/model/budget_view_data.dart';
import 'package:my_wallet/features/categories/domain/category.dart';
import 'package:my_wallet/features/transactions/presentation/model/transaction_view_data.dart';

void main() {
  testWidgets('waits for transactions and budgets before showing budget data', (
    tester,
  ) async {
    final transactions = StreamController<List<TransactionViewData>>();
    final budgets = StreamController<List<BudgetViewData>>();
    addTearDown(transactions.close);
    addTearDown(budgets.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonthlySpendingComparisonCard(
            transactionsStream: transactions.stream,
            budgetsStream: budgets.stream,
          ),
        ),
      ),
    );

    expect(find.byType(HomeCardSkeleton), findsOneWidget);
    expect(find.textContaining('% used'), findsNothing);
    expect(find.textContaining('remaining'), findsNothing);

    transactions.add(const []);
    await tester.pump();

    expect(find.byType(HomeCardSkeleton), findsOneWidget);
    expect(find.textContaining('% used'), findsNothing);
    expect(find.textContaining('remaining'), findsNothing);

    final now = DateTime.now();
    budgets.add([
      BudgetViewData(
        id: 'budget-1',
        categoryId: 'category-1',
        categoryName: 'Food',
        categoryIcon: Icons.restaurant,
        categoryColor: Colors.orange,
        categoryType: CategoryType.expense,
        estimatedAmount: 1000000,
        spentAmount: 0,
        startDate: DateTime(now.year, now.month),
        endDate: DateTime(now.year, now.month + 1, 0),
        createdAt: now,
        updatedAt: now,
      ),
    ]);
    await tester.pump();

    expect(find.byType(HomeCardSkeleton), findsNothing);
    expect(find.text('0% used'), findsOneWidget);
    expect(find.text('1.000.000 đ remaining'), findsOneWidget);
  });
}

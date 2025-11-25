import 'package:flutter/material.dart';
import '../../../../app/di/injector.dart';
import '../../domain/entities/category.dart';
import '../viewmodels/categories_viewmodel.dart';
import '../widgets/categories_header.dart';
import 'category_list.dart';

export '../../domain/entities/category.dart'
    show CategoryType, categoryTypeLabel;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoriesViewModel>();
    _viewModel.loadCategories();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // Header
            const CategoriesHeader(),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: const TabBar(
                isScrollable: false,
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                  Tab(text: 'Debt'),
                  Tab(text: 'Loan'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                children: [
                  CategoryList(
                    type: CategoryType.expense,
                    viewModel: _viewModel,
                    context: context,
                  ),
                  CategoryList(
                    type: CategoryType.income,
                    viewModel: _viewModel,
                    context: context,
                  ),
                  CategoryList(
                    type: CategoryType.debt,
                    viewModel: _viewModel,
                    context: context,
                  ),
                  CategoryList(
                    type: CategoryType.loan,
                    viewModel: _viewModel,
                    context: context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

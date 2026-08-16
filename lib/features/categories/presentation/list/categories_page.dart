import 'package:flutter/material.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../domain/category.dart';
import '../form/add_category_page.dart';
import 'categories_viewmodel.dart';
import 'category_list.dart';
import 'category_type_config.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  static const _types = [
    CategoryType.expense,
    CategoryType.income,
    CategoryType.debt,
    CategoryType.loan,
  ];

  late final CategoriesViewModel _viewModel;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoriesViewModel>();
    _tabController = TabController(
      length: _types.length,
      vsync: this,
      animationDuration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildAddButton(),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Categories',
              onBack: () => Navigator.maybePop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  tabs: const [
                    _TypeTabLabel('Expense'),
                    _TypeTabLabel('Income'),
                    _TypeTabLabel('Debt'),
                    _TypeTabLabel('Loan'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _types.map((type) {
                  return CategoryList(type: type, viewModel: _viewModel);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (context, _) {
        final type = _types[_tabController.index];
        return FloatingActionButton.small(
          onPressed: () => _onAddCategory(type),
          backgroundColor: CategoryTypeConfig.from(type).color,
          foregroundColor: Colors.white,
          tooltip: 'Add category',
          child: const Icon(Icons.add_rounded),
        );
      },
    );
  }

  void _onAddCategory(CategoryType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddCategoryPage(preselectedType: type)),
    );
  }
}

class _TypeTabLabel extends StatelessWidget {
  const _TypeTabLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/category.dart';
import 'categories_viewmodel.dart';
import '../form/add_category_page.dart';
import '../detail/category_detail_page.dart';
import '../detail/category_card.dart';
import './category_empty_state.dart';
import '../model/category_view_data.dart';

class CategoryList extends StatelessWidget {
  final CategoryType type;
  final CategoriesViewModel viewModel;
  final BuildContext context;

  const CategoryList({
    super.key,
    required this.type,
    required this.viewModel,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryViewData>>(
      stream: viewModel.categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final categories = snapshot.data ?? [];
        final items = categories.where((c) => c.type == type).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            children: [
              _buildTabHeader(context),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? CategoryEmptyState(type: type)
                    : _buildCategoriesList(context, items),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_getCategoryLabel()} Categories',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        FilledButton.icon(
          onPressed: () => _onAddCategory(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    List<CategoryViewData> items,
  ) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final category = items[index];
        return CategoryCard(
          category: category,
          onTap: () => _onCategoryTap(context, category),
        );
      },
    );
  }

  void _onCategoryTap(BuildContext context, CategoryViewData category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(id: category.id),
      ),
    );
  }

  Future<void> _onAddCategory(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryPage(preselectedType: type),
      ),
    );
  }

  String _getCategoryLabel() {
    const labels = {
      CategoryType.expense: 'Expense',
      CategoryType.income: 'Income',
      CategoryType.debt: 'Debt',
      CategoryType.loan: 'Loan',
    };
    return labels[type] ?? 'Category';
  }
}

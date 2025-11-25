import 'package:flutter/material.dart';
import '../../../../shared/widgets/notification_widget.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/entities/category.dart';
import '../viewmodels/categories_viewmodel.dart';
import 'add_category_page.dart';
import 'category_detail_page.dart';
import '../widgets/category_card.dart';
import '../widgets/category_empty_state.dart';

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
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return _buildErrorState();
        }

        final items = viewModel.getCategoriesByType(type);

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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            'Error: ${viewModel.error}',
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: viewModel.loadCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(BuildContext context, List<Category> items) {
    return RefreshIndicator(
      onRefresh: viewModel.loadCategories,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final category = items[index];
          return CategoryCard(
            category: category,
            onTap: () => _onCategoryTap(context, category),
          );
        },
      ),
    );
  }

  void _onCategoryTap(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(
          category: category,
          onEdit: () {},
          onDelete: () {},
          onHistory: () {},
        ),
      ),
    ).then((_) {
      // Refresh categories after returning from detail page
      viewModel.loadCategories();
    });
  }

  Future<void> _onAddCategory(BuildContext context) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCategoryPage(preselectedType: type),
      ),
    );

    if (result != null && context.mounted) {
      final category = Category(
        id: UuidGenerator.generate(),
        name: result['name'],
        icon: result['icon'],
        color: result['color'],
        transactionCount: 0,
        amount: 0.0,
        type: result['type'],
        createdOn: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await viewModel.addCategory(category);
      if (context.mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Category "${category.name}" added successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    }
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

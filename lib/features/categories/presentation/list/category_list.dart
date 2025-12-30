import 'package:flutter/material.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/utils/uuid_generator.dart';
import '../../domain/category.dart';
import 'categories_viewmodel.dart';
import '../form/add_category_page.dart';
import '../form/edit_category_page.dart';
import '../detail/category_detail_page.dart';
import '../history/category_history_page.dart';
import '../detail/category_card.dart';
import './category_empty_state.dart';

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
    return StreamBuilder<List<Category>>(
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
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildCategoriesList(BuildContext context, List<Category> items) {
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

  void _onCategoryTap(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailPage(
          category: category,
          onEdit: () => _onEditCategory(context, category),
          onDelete: () => _onDeleteCategory(context, category),
          onHistory: () => _onViewHistory(context, category),
        ),
      ),
    );
  }

  Future<void> _onEditCategory(BuildContext context, Category category) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );

    if (result != null && context.mounted) {
      final updatedCategory = Category(
        id: category.id,
        name: result['name'],
        iconCode: result['icon'],
        type: category.type,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      await viewModel.updateCategory(updatedCategory);
      if (context.mounted) {
        Navigator.pop(context);
        SuccessNotification.show(
          context: context,
          message: 'Category "${updatedCategory.name}" updated successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _onDeleteCategory(
    BuildContext context,
    Category category,
  ) async {
    try {
      await viewModel.deleteCategory(category.id);
      if (context.mounted) {
        Navigator.pop(context);
        SuccessNotification.show(
          context: context,
          message: 'Category "${category.name}" deleted successfully!',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ErrorNotification.show(
          context: context,
          message: 'Category have transactions, can not delete!',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _onViewHistory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHistoryPage(category: category),
      ),
    );
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
        iconCode: result['icon'],
        type: result['type'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
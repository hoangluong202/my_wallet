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
    // Separate parent and child categories
    final parentCategories = items
        .where((c) => c.parentCategoryId == null)
        .toList();

    return ListView.separated(
      itemCount: parentCategories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final parentCategory = parentCategories[index];
        final childCategories = items
            .where((c) => c.parentCategoryId == parentCategory.id)
            .toList();

        return _buildCategoryTree(context, parentCategory, childCategories);
      },
    );
  }

  // NEW: Build tree structure for parent-child relationship
  Widget _buildCategoryTree(
    BuildContext context,
    CategoryViewData parentCategory,
    List<CategoryViewData> childCategories,
  ) {
    // If no children, just show the parent card without wrapper
    if (childCategories.isEmpty) {
      return CategoryCard(
        category: parentCategory,
        onTap: () => _onCategoryTap(context, parentCategory),
      );
    }

    // If has children, show parent and all children in a container
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Parent category card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: CategoryCard(
              category: parentCategory,
              onTap: () => _onCategoryTap(context, parentCategory),
            ),
          ),
          // All child categories
          ...List.generate(childCategories.length, (childIndex) {
            final childCategory = childCategories[childIndex];
            final isLastChild = childIndex == childCategories.length - 1;

            return Column(
              children: [
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 16,
                  endIndent: 16,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: 2,
                              height: 8,
                              child: Container(color: Colors.grey.shade400),
                            ),
                            Container(
                              width: 2,
                              height: isLastChild ? 0 : 20,
                              decoration: BoxDecoration(
                                border: isLastChild
                                    ? null
                                    : Border(
                                        left: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CategoryCard(
                            category: childCategory,
                            onTap: () => _onCategoryTap(context, childCategory),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
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

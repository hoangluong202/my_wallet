import 'package:flutter/material.dart';
import '../../domain/category.dart';
import 'categories_viewmodel.dart';
import '../detail/category_detail_page.dart';
import './category_empty_state.dart';
import '../model/category_view_data.dart';
import 'category_tree_card.dart';

class CategoryList extends StatelessWidget {
  final CategoryType type;
  final CategoriesViewModel viewModel;

  const CategoryList({super.key, required this.type, required this.viewModel});

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

        return items.isEmpty
            ? CategoryEmptyState(type: type)
            : _buildCategoriesList(context, items);
      },
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
    final parentCategories = items
        .where((c) => c.parentCategoryId == null)
        .toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      itemCount: parentCategories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final parentCategory = parentCategories[index];
        final childCategories = items
            .where((c) => c.parentCategoryId == parentCategory.id)
            .toList();

        return CategoryTreeCard(
          parent: parentCategory,
          children: childCategories,
          onTap: (category) => _onCategoryTap(context, category),
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
}

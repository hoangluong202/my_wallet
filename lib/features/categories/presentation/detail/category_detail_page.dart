import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../form/category_icon_section.dart';
import 'category_info_card.dart';
import '../../../wallets/presentation/detail/wallet_action_buttons.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../model/category_view_data.dart';
import '../list/categories_viewmodel.dart';
import '../form/edit_category_page.dart';
import '../history/category_history_page.dart';


class CategoryDetailPage extends StatefulWidget {
  final String id;

  const CategoryDetailPage({super.key, required this.id});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<CategoriesViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<CategoryViewData?>(
          stream: _viewModel.getCategoryStream(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final category = snapshot.data!;

            return Column(
              children: [
                DetailHeader(
                  title: 'Category Details',
                  onBack: () => Navigator.pop(context),
                ),
                _buildContent(context, category),
                const Expanded(child: SizedBox.expand()),
                WalletActionButtons(
                  onEdit: () => _onEdit(context,category),
                  onHistory: () => _onHistory(context, category),
                  onDelete: () => _showDeleteConfirmation(context, category),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CategoryViewData category) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryIconSection(category: category),
            const SizedBox(height: 12),
            CategoryInfoCard(category: category),
          ],
        ),
      ),
    );
  }

  void _onEdit(BuildContext context, CategoryViewData category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryPage(category: category),
      ),
    );
  }

  Future<void> _onHistory(
    BuildContext context,
    CategoryViewData category,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryHistoryPage(category: category),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CategoryViewData category,
  ) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Category?',
      content:
          'Are you sure you want to delete "${category.name}"?\n\n'
          'Note: You can only delete a category if there are no transactions using it. '
          'This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      await _viewModel.deleteCategory(category.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

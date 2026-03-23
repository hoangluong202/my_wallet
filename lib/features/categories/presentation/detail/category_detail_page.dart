import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../../transactions/presentation/detail/transaction_details_page.dart';
import '../form/edit_category_page.dart';
import '../list/categories_viewmodel.dart';
import '../model/category_view_data.dart';
import '../widgets/category_detail_header.dart';
import '../widgets/category_children_section.dart';
import '../widgets/category_parent_section.dart';
import '../widgets/category_transactions_section.dart';

class CategoryDetailPage extends StatefulWidget {
  final String id;

  const CategoryDetailPage({super.key, required this.id});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late final CategoriesViewModel _viewModel;
  late final TransactionRepository _transactionRepository;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<CategoriesViewModel>();
    _transactionRepository = GetIt.instance<TransactionRepository>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<CategoryViewData?>(
          stream: _viewModel.getCategoryStream(widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _ErrorView(error: snapshot.error);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final category = snapshot.data!;

            if (category.parentCategoryId == null) {
              return _buildDetailPage(context, category, null);
            }

            return StreamBuilder<CategoryViewData?>(
              stream: _viewModel.getCategoryStream(category.parentCategoryId!),
              builder: (context, parentSnapshot) {
                return _buildDetailPage(context, category, parentSnapshot.data);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailPage(
    BuildContext context,
    CategoryViewData category,
    CategoryViewData? parentCategory,
  ) {
    return Column(
      children: [
        CategoryDetailHeader(
          category: category,
          onEdit: () => _navigateToEdit(context, category),
          onDelete: () => _showDeleteConfirmation(context, category),
        ),
        Expanded(
          child: _CategoryDetailBody(
            category: category,
            parentCategory: parentCategory,
            viewModel: _viewModel,
            transactionRepository: _transactionRepository,
            onTransactionTap: (transactionId) =>
                _navigateToTransaction(context, transactionId),
            onChildCategoryTap: (id) => _navigateToCategoryDetail(context, id),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _navigateToCategoryDetail(BuildContext context, String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryDetailPage(id: id)),
    );
  }

  void _navigateToEdit(BuildContext context, CategoryViewData category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCategoryPage(category: category)),
    );
  }

  // history navigation removed; history button is no longer displayed in header

  void _navigateToTransaction(BuildContext context, String transactionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailsPage(transactionId: transactionId),
      ),
    );
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CategoryViewData category,
  ) async {
    final confirmed = await context.showConfirmDialog(
      title: 'Delete Category?',
      content:
          'Are you sure you want to delete "${category.name}"?\n\n'
          'Note: You can only delete a category if there are no transactions '
          'using it. This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed != true || !context.mounted) return;

    await _deleteCategory(context, category);
  }

  Future<void> _deleteCategory(
    BuildContext context,
    CategoryViewData category,
  ) async {
    _showLoadingDialog(context);

    try {
      await _viewModel.deleteCategory(category.id);

      if (!context.mounted) return;
      Navigator.pop(context); // close loading
      SuccessNotification.show(
        context: context,
        message: 'Category "${category.name}" deleted successfully',
      );
      if (context.mounted) Navigator.pop(context); // close detail page
    } catch (e) {
      if (!context.mounted) return;
      _safeCloseDialog(context);
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (context.mounted) {
        ErrorNotification.show(context: context, message: errorMessage);
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _safeCloseDialog(BuildContext context) {
    try {
      Navigator.pop(context);
    } catch (_) {
      // Dialog may already be closed
    }
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _CategoryDetailBody extends StatelessWidget {
  final CategoryViewData category;
  final CategoryViewData? parentCategory;
  final CategoriesViewModel viewModel;
  final TransactionRepository transactionRepository;
  final ValueChanged<String> onTransactionTap;
  final ValueChanged<String> onChildCategoryTap;

  const _CategoryDetailBody({
    required this.category,
    required this.parentCategory,
    required this.viewModel,
    required this.transactionRepository,
    required this.onTransactionTap,
    required this.onChildCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (parentCategory != null) ...[
            CategoryParentSection(
              parentCategory: parentCategory!,
              onTap: () => onChildCategoryTap(parentCategory!.id),
            ),
            const SizedBox(height: 12),
          ],
          if (category.parentCategoryId == null)
            CategoryChildrenSection(
              category: category,
              viewModel: viewModel,
              onChildTap: onChildCategoryTap,
            ),
          CategoryTransactionsSection(
            category: category,
            transactionRepository: transactionRepository,
            onTransactionTap: onTransactionTap,
          ),
        ],
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final Object? error;

  const _ErrorView({this.error});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Error: $error'));
  }
}

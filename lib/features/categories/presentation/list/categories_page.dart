import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../transactions/data/repositories/transaction_repository.dart';
import '../../domain/category.dart';
import '../form/add_category_page.dart';
import '../form/edit_category_page.dart';
import '../model/category_view_data.dart';
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
  late final TransactionRepository _transactionRepository;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoriesViewModel>();
    _transactionRepository = getIt<TransactionRepository>();
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
                  return CategoryList(
                    type: type,
                    viewModel: _viewModel,
                    onEdit: _onEditCategory,
                    onDelete: _onDeleteCategory,
                  );
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

  void _onEditCategory(CategoryViewData category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCategoryPage(category: category)),
    );
  }

  Future<void> _onDeleteCategory(CategoryViewData category) async {
    try {
      final transactions = await _transactionRepository
          .getTransactionsByCategory(category.id);
      if (!mounted) return;

      String? transferToCategoryId;
      if (transactions.isEmpty) {
        final confirmed = await context.showConfirmDialog(
          title: 'Delete Category?',
          content:
              'Are you sure you want to delete "${category.name}"?\n\n'
              'This action cannot be undone.',
          confirmText: 'Delete',
          cancelText: 'Cancel',
          isDangerous: true,
        );
        if (confirmed != true || !mounted) return;
      } else {
        transferToCategoryId = await _showTransferSelectionDialog(
          category,
          transactions.length,
        );
        if (transferToCategoryId == null || !mounted) return;
      }

      _showLoadingDialog();
      await _viewModel.deleteCategory(
        category.id,
        transferToCategoryId: transferToCategoryId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      SuccessNotification.show(
        context: context,
        message: 'Category "${category.name}" deleted successfully',
      );
    } catch (error) {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        final route = ModalRoute.of(context);
        if (route?.isCurrent == false) Navigator.pop(context);
      }
      ErrorNotification.show(
        context: context,
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<String?> _showTransferSelectionDialog(
    CategoryViewData category,
    int transactionCount,
  ) {
    String? selectedCategoryId;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Move transactions before deleting?'),
            content: SizedBox(
              width: 360,
              child: StreamBuilder<List<CategoryViewData>>(
                stream: _viewModel.categoriesStream,
                builder: (context, snapshot) {
                  final options = (snapshot.data ?? <CategoryViewData>[])
                      .where(
                        (item) =>
                            item.id != category.id &&
                            item.type == category.type,
                      )
                      .toList();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${category.name}" has $transactionCount '
                        'transaction${transactionCount > 1 ? 's' : ''}. '
                        'Choose a category to move them to.',
                      ),
                      const SizedBox(height: 16),
                      if (options.isEmpty)
                        const Text(
                          'No other category of the same type is available.',
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Destination category',
                            border: OutlineInputBorder(),
                          ),
                          items: options
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setDialogState(() => selectedCategoryId = value),
                        ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selectedCategoryId == null
                    ? null
                    : () => Navigator.pop(dialogContext, selectedCategoryId),
                child: const Text('Move & Delete'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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

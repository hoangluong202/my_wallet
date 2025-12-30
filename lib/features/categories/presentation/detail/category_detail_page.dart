import 'package:flutter/material.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../domain/category.dart';
import '../form/category_icon_section.dart';
import 'category_info_card.dart';
import '../../../wallets/presentation/detail/wallet_action_buttons.dart';
import '../../../../core/extensions/context_extensions.dart';

class CategoryDetailPage extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onHistory;

  const CategoryDetailPage({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Category Details',
              onBack: () => Navigator.pop(context),
            ),
            _buildContent(context),
            const Expanded(child: SizedBox.expand()),
            WalletActionButtons(
              onEdit: onEdit,
              onHistory: onHistory,
              onDelete: () => _showDeleteConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
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

  Future<void> _showDeleteConfirmation(BuildContext context) async {
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
      Navigator.pop(context); // Close detail page
      onDelete();
    }
  }
}

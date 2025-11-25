import 'package:flutter/material.dart';
import '../../../../shared/widgets/header/detail_header.dart';
import '../../domain/entities/category.dart';
import '../widgets/category_icon_section.dart';
import '../widgets/category_info_card.dart';
import '../../../wallets/presentation/widgets/wallet_action_buttons.dart';

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'All transactions related to this category will also be deleted. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onDelete();
      Navigator.pop(context);
    }
  }
}

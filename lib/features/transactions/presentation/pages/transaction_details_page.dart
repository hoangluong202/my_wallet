import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/dialogs/confirm_dialog.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../data/models/transaction_item.dart';
import '../../../categories/domain/entities/category.dart';
import '../widgets/transaction_action_buttons.dart';
import 'edit_transaction_page.dart';
import '../../../../core/di/injector.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import '../../../wallets/presentation/viewmodels/wallets_viewmodel.dart';

class TransactionDetailsPage extends StatefulWidget {
  final TransactionItem initialTransaction;

  const TransactionDetailsPage({super.key, required this.initialTransaction});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late TransactionItem transaction;
  bool _hasChanges = false; // Track if transaction was edited
  bool _isLoading = false;

  // ViewModels
  late TransactionsViewModel _transactionsViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  @override
  void initState() {
    super.initState();
    transaction = widget.initialTransaction;

    // Initialize ViewModels
    _transactionsViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();
  }

  Future<void> _reloadTransaction() async {
    setState(() => _isLoading = true);

    try {
      // Reload all data to ensure we have latest info
      await Future.wait([
        _transactionsViewModel.loadTransactions(),
        _categoriesViewModel.loadCategories(),
        _walletsViewModel.loadWallets(),
      ]);

      // Find the updated transaction
      final updatedTransaction = _transactionsViewModel.transactions.firstWhere(
        (t) => t.id == transaction.id,
        orElse: () => throw Exception('Transaction not found after reload'),
      );

      // Get category info
      final category = _categoriesViewModel.categories.firstWhere(
        (c) => c.id == updatedTransaction.categoryId,
        orElse: () => throw Exception('Category not found'),
      );

      // Get wallet info
      final wallet = _walletsViewModel.wallets.firstWhere(
        (w) => w.id == updatedTransaction.walletId,
        orElse: () => throw Exception('Wallet not found'),
      );

      // Map category type to transaction type
      TransactionType transactionType;
      switch (category.type) {
        case CategoryType.income:
          transactionType = TransactionType.income;
          break;
        case CategoryType.expense:
          transactionType = TransactionType.expense;
          break;
        case CategoryType.debt:
          transactionType = TransactionType.debt;
          break;
        case CategoryType.loan:
          transactionType = TransactionType.loan;
          break;
      }

      // Create updated TransactionItem
      final updatedItem = TransactionItem(
        id: updatedTransaction.id,
        description: updatedTransaction.note ?? '',
        category: category.name,
        amount: updatedTransaction.amount,
        type: transactionType,
        categoryIcon: category.icon,
        date: updatedTransaction.transactionDate,
        walletName: wallet.name,
      );

      if (mounted) {
        setState(() {
          transaction = updatedItem;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ErrorNotification.show(
          context: context,
          message: 'Failed to reload transaction: $e',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to parent if transaction was edited
        Navigator.pop(context, _hasChanges);
        return false; // Prevent default pop
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  DetailHeader(
                    title: 'Transaction Details',
                    onBack: () => Navigator.pop(context, _hasChanges),
                  ),
                  Expanded(child: _buildContent(context)),
                  TransactionActionButtons(
                    onEdit: () => _onEditTransaction(context),
                    onDelete: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Determine colors, icons, and labels based on transaction type
    final Color amountColor;
    final IconData typeIcon;
    final String typeLabel;
    final String amountPrefix;

    switch (transaction.type) {
      case TransactionType.income:
        amountColor = Colors.green.shade700;
        typeIcon = Icons.arrow_upward;
        typeLabel = 'Income';
        amountPrefix = '+';
        break;
      case TransactionType.expense:
        amountColor = Colors.red;
        typeIcon = Icons.arrow_downward;
        typeLabel = 'Expense';
        amountPrefix = '-';
        break;
      case TransactionType.debt:
        amountColor = Colors.orange.shade700;
        typeIcon = Icons.arrow_upward;
        typeLabel = 'Debt';
        amountPrefix = '+';
        break;
      case TransactionType.loan:
        amountColor = Colors.purple.shade700;
        typeIcon = Icons.arrow_downward;
        typeLabel = 'Loan';
        amountPrefix = '-';
        break;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Main Transaction Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with Icon and Amount
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        amountColor.withOpacity(0.1),
                        amountColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Icon with enhanced design
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: amountColor.withOpacity(0.15),
                            ),
                          ),
                          // Icon container
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: amountColor.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              transaction.categoryIcon,
                              color: amountColor,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Amount and Type section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    amountColor,
                                    amountColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: amountColor.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(typeIcon, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    typeLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Amount
                            Text(
                              '$amountPrefix${CurrencyFormatter.formatVND(transaction.amount)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: amountColor,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),

                            // Currency symbol
                            Text(
                              'VND',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: amountColor.withOpacity(0.7),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Category
                      _buildInfoRow(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: transaction.category,
                        iconColor: Colors.purple,
                      ),
                      const Divider(height: 24),

                      // Date
                      _buildInfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: _formatDate(transaction.date),
                        iconColor: Colors.blue,
                      ),
                      const Divider(height: 24),

                      // Wallet
                      _buildInfoRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Wallet',
                        value: transaction.walletName,
                        iconColor: Colors.orange,
                      ),
                      const Divider(height: 24),

                      // Description
                      _buildInfoRow(
                        icon: Icons.notes_outlined,
                        label: 'Note',
                        value: transaction.description.isEmpty
                            ? 'No note'
                            : transaction.description,
                        iconColor: Colors.teal,
                        isMultiline: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),

        // Label and Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  void _onEditTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    );

    // If edit was successful, reload transaction data and show notification
    if (result == true && context.mounted) {
      // Reload transaction to get updated data
      await _reloadTransaction();

      setState(() {
        _hasChanges = true; // Mark that changes were made
      });

      if (context.mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Transaction updated successfully',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Transaction?',
      content:
          'Are you sure you want to delete "${transaction.description}"?\n\n'
          'This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed == true && context.mounted) {
      try {
        // Delete from database
        final transactionsViewModel = getIt<TransactionsViewModel>();
        await transactionsViewModel.deleteTransaction(transaction.id);

        if (context.mounted) {
          // Show success notification
          SuccessNotification.show(
            context: context,
            message: 'Transaction "${transaction.description}" deleted',
            duration: const Duration(seconds: 2),
          );

          // Wait a moment for notification to show, then pop with result = true
          await Future.delayed(const Duration(milliseconds: 300));

          if (context.mounted) {
            Navigator.pop(context, true); // Return true to trigger reload
          }
        }
      } catch (e) {
        if (context.mounted) {
          ErrorNotification.show(
            context: context,
            message: 'Failed to delete transaction: $e',
            duration: const Duration(seconds: 3),
          );
        }
      }
    }
  }
}

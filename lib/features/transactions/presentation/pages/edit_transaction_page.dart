import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../data/models/transaction_item.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import '../../../wallets/ui/viewmodels/wallets_viewmodel.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../wallets/domain/entities/wallet.dart';

// Custom formatter for thousand separator
class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all dots (thousand separators)
    String text = newValue.text.replaceAll('.', '');

    // Only allow digits
    if (!RegExp(r'^\d+$').hasMatch(text)) {
      return oldValue;
    }

    // Format with thousand separators
    final number = int.tryParse(text);
    if (number == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,##0', 'en_US');
    final formatted = formatter.format(number).replaceAll(',', '.');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditTransactionPage extends StatefulWidget {
  final TransactionItem transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  // ViewModels
  late TransactionsViewModel _transactionsViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  // Selected values (using IDs now)
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String _selectedCategoryType = 'Expense';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize ViewModels
    _transactionsViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();

    // Initialize with transaction data
    _amountController = TextEditingController(
      text: _formatAmount(widget.transaction.amount),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
    _selectedDate = widget.transaction.date;

    // Get type from transaction to determine category type (read-only in edit mode)
    _selectedCategoryType = switch (widget.transaction.type) {
      TransactionType.income => 'Income',
      TransactionType.expense => 'Expense',
      TransactionType.debt => 'Debt',
      TransactionType.loan => 'Loan',
    };

    // Load data from database
    _loadData();
  }

  // Load data from database
  Future<void> _loadData() async {
    await _categoriesViewModel.loadCategories();
    await _walletsViewModel.loadWallets();

    // Set initial selections based on transaction
    // We'll find the category and wallet by name for now
    final categories = _categoriesViewModel.categories;
    final wallets = _walletsViewModel.wallets;

    // Convert string type to enum
    final categoryTypeEnum = switch (_selectedCategoryType) {
      'Income' => CategoryType.income,
      'Expense' => CategoryType.expense,
      'Debt' => CategoryType.debt,
      'Loan' => CategoryType.loan,
      _ => CategoryType.expense,
    };

    // Find matching category
    try {
      final matchingCategory = categories.firstWhere(
        (cat) => cat.name == widget.transaction.category,
      );
      _selectedCategoryId = matchingCategory.id;
    } catch (e) {
      // If no matching category found, use first category of the type
      final categoriesOfType = categories
          .where((cat) => cat.type == categoryTypeEnum)
          .toList();
      if (categoriesOfType.isNotEmpty) {
        _selectedCategoryId = categoriesOfType.first.id;
      } else if (categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      }
    }

    // For wallet, we'll use the first available wallet
    // (transaction doesn't store wallet info in TransactionItem)
    if (wallets.isNotEmpty) {
      _selectedWalletId = wallets.first.id;
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Format amount with thousand separator (30000 -> 30.000)
  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    // Format with comma, then replace comma with dot for display
    return formatter.format(amount).replaceAll(',', '.');
  }

  // Parse amount from formatted string (30.000 -> 30000)
  double _parseAmount(String text) {
    // Remove thousand separators (dots) and parse
    final cleanText = text.replaceAll('.', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Validate that category and wallet are selected
      if (_selectedCategoryId == null) {
        ErrorNotification.show(
          context: context,
          message: 'Please select a category',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      if (_selectedWalletId == null) {
        ErrorNotification.show(
          context: context,
          message: 'Please select a wallet',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      try {
        // Create updated Transaction entity
        final now = DateTime.now();
        final updatedTransaction = Transaction(
          id: widget.transaction.id, // Keep same ID for update
          categoryId: _selectedCategoryId!,
          walletId: _selectedWalletId!,
          amount: _parseAmount(_amountController.text),
          note: _descriptionController.text,
          transactionDate: _selectedDate,
          createdAt: now, // Will be ignored by update, but required by model
          updatedAt: now,
        );

        // Save to database via ViewModel
        await _transactionsViewModel.updateTransaction(updatedTransaction);

        if (mounted) {
          // Pop back with result to trigger reload
          // Note: Success notification will be shown by parent page
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ErrorNotification.show(
            context: context,
            message: 'Failed to update transaction: $e',
            duration: const Duration(seconds: 3),
          );
        }
      }
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DetailHeader(
                    title: 'Edit Transaction',
                    onBack: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Type Display (Read-only) - Show current type
                            _buildCategoryTypeDisplay(),
                            const SizedBox(height: 16),

                            // Main Form Card
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
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
                                  // Category Section
                                  _buildCardSection(
                                    title: 'Category',
                                    icon: Icons.category_outlined,
                                    child: _buildCategorySelector(),
                                  ),

                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),

                                  // Amount Section
                                  _buildCardSection(
                                    title: 'Amount',
                                    icon: Icons.payments_outlined,
                                    child: TextFormField(
                                      controller: _amountController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        ThousandSeparatorInputFormatter(),
                                      ],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          fontSize: 24,
                                          color: Colors.grey.shade300,
                                        ),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12.0,
                                            top: 12,
                                          ),
                                          child: Text(
                                            '₫',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        suffixIconConstraints:
                                            const BoxConstraints(minWidth: 0),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter an amount';
                                        }
                                        final amount = _parseAmount(value);
                                        if (amount <= 0) {
                                          return 'Please enter a valid amount greater than 0';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),

                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),

                                  // Wallet Section
                                  _buildCardSection(
                                    title: 'Wallet',
                                    icon: Icons.account_balance_wallet_outlined,
                                    child: _buildWalletSelector(),
                                  ),

                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),

                                  // Date Section
                                  _buildCardSection(
                                    title: 'Date',
                                    icon: Icons.calendar_today_outlined,
                                    child: _buildDateSelector(),
                                  ),

                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),

                                  // Note Section
                                  _buildCardSection(
                                    title: 'Note',
                                    icon: Icons.notes_outlined,
                                    child: TextFormField(
                                      controller: _descriptionController,
                                      keyboardType: TextInputType.text,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: 'Add a note (optional)',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Submit Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade600,
                                    Colors.blue.shade700,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Update Transaction',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Category> _getFilteredCategories() {
    // Convert string type to enum for comparison
    final categoryTypeEnum = switch (_selectedCategoryType) {
      'Income' => CategoryType.income,
      'Expense' => CategoryType.expense,
      'Debt' => CategoryType.debt,
      'Loan' => CategoryType.loan,
      _ => CategoryType.expense,
    };

    return _categoriesViewModel.categories
        .where((cat) => cat.type == categoryTypeEnum)
        .toList();
  }

  Widget _buildCategoryTypeDisplay() {
    // Get type info for display
    final typeInfo = switch (_selectedCategoryType) {
      'Income' => {
        'icon': Icons.add_circle,
        'color': Colors.green,
        'label': 'Income',
      },
      'Expense' => {
        'icon': Icons.remove_circle,
        'color': Colors.red,
        'label': 'Expense',
      },
      'Debt' => {
        'icon': Icons.account_balance,
        'color': Colors.orange,
        'label': 'Debt',
      },
      'Loan' => {
        'icon': Icons.savings,
        'color': Colors.purple,
        'label': 'Loan',
      },
      _ => {
        'icon': Icons.remove_circle,
        'color': Colors.red,
        'label': 'Expense',
      },
    };

    final icon = typeInfo['icon'] as IconData;
    final color = typeInfo['color'] as Color;
    final label = typeInfo['label'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Type',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSelector() {
    return _selectedWalletId == null
        ? _buildWalletSelectionGrid()
        : _buildSelectedWalletCard();
  }

  Widget _buildWalletSelectionGrid() {
    return GestureDetector(
      onTap: _showWalletPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.grey.shade500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select a wallet',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSelectedWalletCard() {
    if (_selectedWalletId == null) {
      return _buildWalletSelectionGrid();
    }

    // Find wallet, fallback to first if not found
    Wallet? wallet;
    try {
      wallet = _walletsViewModel.wallets.firstWhere(
        (w) => w.id == _selectedWalletId,
      );
    } catch (e) {
      wallet = _walletsViewModel.wallets.isNotEmpty
          ? _walletsViewModel.wallets.first
          : null;
    }

    if (wallet == null) {
      return _buildWalletSelectionGrid();
    }

    return GestureDetector(
      onTap: _showWalletPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: wallet.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(wallet.icon, color: wallet.iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${CurrencyFormatter.formatVND(wallet.balance)} đ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: wallet.balance >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showWalletPicker() {
    final wallets = _walletsViewModel.wallets;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Wallet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...wallets.map((wallet) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWalletId = wallet.id;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: wallet.iconColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: wallet.iconColor.withOpacity(0.2),
                        child: Icon(
                          wallet.icon,
                          color: wallet.iconColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        wallet.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return _selectedCategoryId == null
        ? _buildCategorySelectionGrid()
        : _buildSelectedCategoryCard();
  }

  Widget _buildCategorySelectionGrid() {
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.grey.shade500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select a category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryCard() {
    if (_selectedCategoryId == null) {
      return _buildCategorySelectionGrid();
    }

    // Find category, fallback to first if not found
    Category? category;
    try {
      category = _categoriesViewModel.categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
      );
    } catch (e) {
      category = _categoriesViewModel.categories.isNotEmpty
          ? _categoriesViewModel.categories.first
          : null;
    }

    if (category == null) {
      return _buildCategorySelectionGrid();
    }

    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    final filteredCategories = _getFilteredCategories();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: category.color.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: category.color.withOpacity(0.2),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(now.year - 10),
          lastDate: DateTime(now.year + 10),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_month,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

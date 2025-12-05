import 'package:flutter/material.dart';
import '../../data/models/transaction_item.dart';
import '../../../../core/widgets/header/detail_header.dart';

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

  // Editable selections
  String? _selectedWallet;
  String? _selectedCategory;
  String _selectedCategoryType = 'Expense';

  // Wallet data with icons and colors
  final List<Map<String, dynamic>> _wallets = [
    {
      'name': 'Main Bank Account',
      'icon': Icons.account_balance,
      'color': Colors.blue,
    },
    {
      'name': 'Momo Wallet',
      'icon': Icons.mobile_friendly,
      'color': Colors.pink,
    },
    {'name': 'Savings', 'icon': Icons.savings, 'color': Colors.green},
    {'name': 'Crypto', 'icon': Icons.currency_bitcoin, 'color': Colors.orange},
  ];

  // Category data with icons and types
  final List<Map<String, dynamic>> _categories = [
    // Expense
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.red,
      'type': 'Expense',
    },
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'type': 'Expense',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_cart,
      'color': Colors.purple,
      'type': 'Expense',
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.orange,
      'type': 'Expense',
    },
    {
      'name': 'Utilities',
      'icon': Icons.electric_bolt,
      'color': Colors.amber,
      'type': 'Expense',
    },
    // Income
    {
      'name': 'Salary',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'type': 'Income',
    },
    {
      'name': 'Freelance',
      'icon': Icons.work,
      'color': Colors.lightGreen,
      'type': 'Income',
    },
    {
      'name': 'Bonus',
      'icon': Icons.card_giftcard,
      'color': Colors.teal,
      'type': 'Income',
    },
    // Debt
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'color': Colors.red,
      'type': 'Debt',
    },
    {
      'name': 'Personal Loan',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'type': 'Debt',
    },
    {
      'name': 'Other Debt',
      'icon': Icons.assignment,
      'color': Colors.pink,
      'type': 'Debt',
    },
    // Loan
    {
      'name': 'Home Loan',
      'icon': Icons.home,
      'color': Colors.blue,
      'type': 'Loan',
    },
    {
      'name': 'Auto Loan',
      'icon': Icons.directions_car,
      'color': Colors.indigo,
      'type': 'Loan',
    },
    {
      'name': 'Education Loan',
      'icon': Icons.school,
      'color': Colors.deepPurple,
      'type': 'Loan',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with transaction data
    _amountController = TextEditingController(
      text: widget.transaction.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.transaction.description,
    );
    _selectedDate = widget.transaction.date;

    // Initialize wallet - use first wallet as default
    _selectedWallet = _wallets.isNotEmpty
        ? _wallets[0]['name'] as String
        : null;

    // Try to find matching category, otherwise use first Expense category
    try {
      final matchingCategory = _categories.firstWhere(
        (cat) => cat['name'] == widget.transaction.category,
      );
      _selectedCategory = matchingCategory['name'] as String;
      _selectedCategoryType = matchingCategory['type'] as String;
    } catch (e) {
      // If category not found, use first category of default type
      final defaultCategories = _categories
          .where((cat) => cat['type'] == 'Expense')
          .toList();
      if (defaultCategories.isNotEmpty) {
        _selectedCategory = defaultCategories[0]['name'] as String;
        _selectedCategoryType = 'Expense';
      } else {
        _selectedCategory = null;
        _selectedCategoryType = 'Expense';
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate that category is selected
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Form is valid
      final selectedCategoryData = _categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
        orElse: () => _categories[0],
      );

      final updatedTransaction = {
        'wallet': _selectedWallet,
        'category': _selectedCategory,
        'categoryType': selectedCategoryData['type'],
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'date': _selectedDate,
      };

      debugPrint('Transaction updated: $updatedTransaction');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaction "${_descriptionController.text}" updated successfully!',
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Pop back to previous page after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
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
                      // Category Type Selector - Prominent at top
                      _buildCategoryTypeSelector(),
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

                            Divider(height: 1, color: Colors.grey.shade200),

                            // Amount Section
                            _buildCardSection(
                              title: 'Amount',
                              icon: Icons.payments_outlined,
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
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
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null || amount <= 0) {
                                    return 'Please enter a valid amount greater than 0';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            Divider(height: 1, color: Colors.grey.shade200),

                            // Wallet Section
                            _buildCardSection(
                              title: 'Wallet',
                              icon: Icons.account_balance_wallet_outlined,
                              child: _buildWalletSelector(),
                            ),

                            Divider(height: 1, color: Colors.grey.shade200),

                            // Date Section
                            _buildCardSection(
                              title: 'Date',
                              icon: Icons.calendar_today_outlined,
                              child: _buildDateSelector(),
                            ),

                            Divider(height: 1, color: Colors.grey.shade200),

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

  List<Map<String, dynamic>> _getFilteredCategories() {
    return _categories
        .where((cat) => cat['type'] == _selectedCategoryType)
        .toList();
  }

  Widget _buildCategoryTypeSelector() {
    final categoryTypes = [
      {'type': 'Expense', 'icon': Icons.remove_circle, 'color': Colors.red},
      {'type': 'Income', 'icon': Icons.add_circle, 'color': Colors.green},
      {'type': 'Debt', 'icon': Icons.account_balance, 'color': Colors.orange},
      {'type': 'Loan', 'icon': Icons.savings, 'color': Colors.purple},
    ];

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
      padding: const EdgeInsets.all(12),
      child: Row(
        children: List.generate(categoryTypes.length, (index) {
          final item = categoryTypes[index];
          final type = item['type'] as String;
          final icon = item['icon'] as IconData;
          final color = item['color'] as Color;
          final isSelected = _selectedCategoryType == type;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryType = type;
                  // Reset category selection to first category of new type
                  final filteredCategories = _getFilteredCategories();
                  if (filteredCategories.isNotEmpty) {
                    _selectedCategory = filteredCategories[0]['name'];
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: index == categoryTypes.length - 1 ? 0 : 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? color : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected ? color : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWalletSelector() {
    return _selectedWallet == null
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
    if (_selectedWallet == null) {
      return _buildWalletSelectionGrid();
    }
    final wallet = _wallets.firstWhere(
      (w) => w['name'] == _selectedWallet,
      orElse: () => _wallets[0],
    );
    return GestureDetector(
      onTap: _showWalletPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (wallet['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              wallet['icon'] as IconData,
              color: wallet['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              wallet['name'] as String,
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

  void _showWalletPicker() {
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
            ...List.generate(_wallets.length, (index) {
              final wallet = _wallets[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedWallet = wallet['name'];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (wallet['color'] as Color).withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: (wallet['color'] as Color).withOpacity(
                          0.2,
                        ),
                        child: Icon(
                          wallet['icon'] as IconData,
                          color: wallet['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        wallet['name'] as String,
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
    return _selectedCategory == null
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
    if (_selectedCategory == null) {
      return _buildCategorySelectionGrid();
    }
    final category = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
      orElse: () => _categories[0],
    );
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category['icon'] as IconData,
              color: category['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category['name'] as String,
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
                itemCount: _getFilteredCategories().length,
                itemBuilder: (context, index) {
                  final category = _getFilteredCategories()[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: (category['color'] as Color).withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: (category['color'] as Color)
                                .withOpacity(0.2),
                            child: Icon(
                              category['icon'] as IconData,
                              color: category['color'] as Color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['type'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  category['name'] as String,
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

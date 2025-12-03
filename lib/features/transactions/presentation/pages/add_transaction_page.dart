import 'package:flutter/material.dart';
import '../../../../core/widgets/header/detail_header.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  // Selected values
  String? _selectedWallet;
  String? _selectedCategory;
  String _selectedCategoryType = 'Expense'; // Default to Expense
  DateTime _selectedDate = DateTime.now(); // Default to today

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
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // Set default wallet to first wallet
    _selectedWallet = _wallets[0]['name'];

    // Set default category to first Expense category
    _selectedCategory = _categories.firstWhere(
      (cat) => cat['type'] == _selectedCategoryType,
    )['name'];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid (wallet and category already have defaults)
      final selectedCategoryData = _categories.firstWhere(
        (cat) => cat['name'] == _selectedCategory,
      );

      final transactionData = {
        'wallet': _selectedWallet,
        'category': _selectedCategory,
        'categoryType': selectedCategoryData['type'],
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'date': _selectedDate,
      };

      debugPrint('Transaction added: $transactionData');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully!'),
          duration: Duration(seconds: 2),
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
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Add Transaction',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scrollable content area
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wallet Selector Section
                              _buildSectionTitle('Select Wallet'),
                              const SizedBox(height: 12),
                              _buildWalletSelector(),
                              const SizedBox(height: 20),

                              // Category Selector Section
                              _buildSectionTitle('Select Category Type'),
                              const SizedBox(height: 12),
                              _buildCategoryTypeSelector(),
                              const SizedBox(height: 16),

                              _buildSectionTitle('Select Category'),
                              const SizedBox(height: 12),
                              _buildCategorySelector(),
                              const SizedBox(height: 20),

                              // Date Selector Section
                              _buildSectionTitle('Date'),
                              const SizedBox(height: 8),
                              _buildDateSelector(),
                              const SizedBox(height: 20),

                              // Amount Input Section
                              _buildSectionTitle('Amount'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: _buildInputDecoration(
                                  'Amount',
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
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
                              const SizedBox(height: 16),

                              // Note Section
                              _buildSectionTitle('Note'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _descriptionController,
                                keyboardType: TextInputType.text,
                                maxLines: 3,
                                decoration: _buildInputDecoration(
                                  'Note',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Fixed Submit Button at bottom
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.calendar_today,
                color: Colors.grey.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar,
              color: Colors.blueGrey.shade600,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTypeSelector() {
    final categoryTypes = ['Expense', 'Income', 'Debt', 'Loan'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(categoryTypes.length, (index) {
          final type = categoryTypes[index];
          final isSelected = _selectedCategoryType == type;
          return Padding(
            padding: EdgeInsets.only(
              right: index == categoryTypes.length - 1 ? 0 : 8,
            ),
            child: FilterChip(
              label: Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryType = type;
                  // Reset category selection to first category of new type
                  final filteredCategories = _getFilteredCategories();
                  if (filteredCategories.isNotEmpty) {
                    _selectedCategory = filteredCategories[0]['name'];
                  }
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              'Tap to select wallet',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedWalletCard() {
    final wallet = _wallets.firstWhere((w) => w['name'] == _selectedWallet);
    return GestureDetector(
      onTap: _showWalletPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: (wallet['color'] as Color).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: (wallet['color'] as Color).withOpacity(0.1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (wallet['color'] as Color).withOpacity(0.2),
              child: Icon(
                wallet['icon'] as IconData,
                color: wallet['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    wallet['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: wallet['color'] as Color, size: 24),
          ],
        ),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 8),
            Text(
              'Tap to select category',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCategoryCard() {
    final category = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
    );
    return GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: (category['color'] as Color).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: (category['color'] as Color).withOpacity(0.1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (category['color'] as Color).withOpacity(0.2),
              child: Icon(
                category['icon'] as IconData,
                color: category['color'] as Color,
                size: 24,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    category['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.check_circle,
              color: category['color'] as Color,
              size: 24,
            ),
          ],
        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? prefixIcon,
    BoxConstraints? prefixIconConstraints,
    Widget? suffixIcon,
    BoxConstraints? suffixIconConstraints,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      prefixIconConstraints: prefixIconConstraints,
      suffixIcon: suffixIcon,
      suffixIconConstraints: suffixIconConstraints,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

import 'package:flutter/material.dart';

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

  // Dummy wallet data
  final List<String> _wallets = [
    'Main Wallet',
    'Savings',
    'Momo',
    'Credit Card',
  ];

  // Categories grouped by type
  final Map<String, List<String>> _categoriesMap = {
    'Expense': [
      'Expense - Food',
      'Expense - Transport',
      'Expense - Shopping',
      'Expense - Entertainment',
      'Expense - Utilities',
    ],
    'Income': [
      'Income - Salary',
      'Income - Freelance',
      'Income - Bonus',
      'Income - Interest',
    ],
    'Debt': ['Debt - Credit Card', 'Debt - Personal Loan', 'Debt - Other'],
    'Loan': ['Loan - Home', 'Loan - Auto', 'Loan - Education'],
  };

  late List<String> _allCategories;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // Flatten all categories into a single list
    _allCategories = _categoriesMap.values.expand((list) => list).toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedWallet == null) {
        _showError('Please select a wallet');
        return;
      }
      if (_selectedCategory == null) {
        _showError('Please select a category');
        return;
      }

      // Form is valid
      final transactionData = {
        'wallet': _selectedWallet,
        'category': _selectedCategory,
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('+ Add New Transaction'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Close',
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet Selector
                _buildSectionTitle('Select Wallet'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedWallet,
                  items: _wallets
                      .map(
                        (wallet) => DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWallet = value;
                    });
                  },
                  decoration: _buildInputDecoration('Choose a wallet'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a wallet';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category Selector
                _buildSectionTitle('Select Category'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _allCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: _buildInputDecoration('Choose a category'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Amount Input
                _buildSectionTitle('Amount'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _buildInputDecoration(
                    'Enter amount (e.g., 25.50)',
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
                const SizedBox(height: 20),

                // Description (Optional)
                _buildSectionTitle('Description (Optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  decoration: _buildInputDecoration(
                    'Add a note or description',
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Transaction',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  InputDecoration _buildInputDecoration(String hintText, {int maxLines = 1}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}

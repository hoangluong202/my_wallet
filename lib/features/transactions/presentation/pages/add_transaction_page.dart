import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/di/injector.dart';
import '../viewmodels/transactions_viewmodel.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import '../../../wallets/presentation/viewmodels/wallets_viewmodel.dart';
import '../../domain/entities/transaction.dart';
import '../../../categories/domain/entities/category.dart';

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

  // ViewModels
  late TransactionsViewModel _transactionsViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  // Selected values
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String _selectedCategoryType = 'Expense'; // Default to Expense
  DateTime _selectedDate = DateTime.now(); // Default to today

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // Initialize ViewModels
    _transactionsViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load categories and wallets
    await Future.wait([
      _categoriesViewModel.loadCategories(),
      _walletsViewModel.loadWallets(),
    ]);

    // Set default selections
    if (_walletsViewModel.wallets.isNotEmpty) {
      _selectedWalletId = _walletsViewModel.wallets.first.id;
    }

    // Set default category based on type
    final expenseCategories = _categoriesViewModel.categories
        .where((cat) => cat.type.name == 'expense')
        .toList();
    if (expenseCategories.isNotEmpty) {
      _selectedCategoryId = expenseCategories.first.id;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedWalletId == null || _selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select wallet and category'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        // Create transaction entity
        final transaction = Transaction(
          id: const Uuid().v4(),
          categoryId: _selectedCategoryId!,
          walletId: _selectedWalletId!,
          amount: double.parse(_amountController.text),
          note: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          transactionDate: _selectedDate,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save transaction
        await _transactionsViewModel.addTransaction(transaction);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Pop back to previous page
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: 'Add Transaction',
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
                            'Save Transaction',
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
    return _categoriesViewModel.categories
        .where((cat) => cat.type.name == _selectedCategoryType.toLowerCase())
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
                    _selectedCategoryId = filteredCategories[0].id;
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
    final wallet = _walletsViewModel.wallets.firstWhere(
      (w) => w.id == _selectedWalletId,
    );
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
            child: Text(
              wallet.name,
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
            ...List.generate(_walletsViewModel.wallets.length, (index) {
              final wallet = _walletsViewModel.wallets[index];
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
    final category = _categoriesViewModel.categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );
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

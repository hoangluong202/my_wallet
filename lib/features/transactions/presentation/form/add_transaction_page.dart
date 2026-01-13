import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../categories/domain/category.dart';
import 'transaction_form_state.dart';
import '../../../categories/presentation/constants/category_icons.dart';
import '../../../categories/presentation/helpers/label.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import '../../../../core/utils/thousand_separator_input_formatter.dart';
import 'transaction_payload.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late TransactionsViewModel _transactionViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  late TransactionFormState _formState;

  List<CategoryViewData> _allCategories = [];
  List<WalletViewData> _allWallets = [];

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _noteController = TextEditingController();

    _transactionViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();

    _formState = TransactionFormState.initial();

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      _allCategories = await _categoriesViewModel.categoriesStream.first;
      _allWallets = await _walletsViewModel.walletsStream.first;

      if (_allCategories.isNotEmpty && _allWallets.isNotEmpty) {
        final firstCategory = _allCategories
            .where((c) => c.type == _formState.selectedType)
            .firstOrNull;

        setState(() {
          _formState = _formState.copyWith(
            selectedCategoryId: firstCategory?.id,
            selectedWalletId: _allWallets.first.id,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return DetailHeader(
      title: 'Add Transaction',
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryTypeSelector(),
            const SizedBox(height: 16),
            _buildFormCard(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTypeSelector() {
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
        children: CategoryTypeIcons.typeIcons.entries.map((entry) {
          final type = entry.key;
          final isSelected = _formState.selectedType == type;
          final typeIcon = entry.value;
          final label = LabelHelper.getCategoryLabel(type);
          return Expanded(
            child: _buildTypeChip(
              typeIcon: typeIcon,
              label: label,
              isSelected: isSelected,
              onTap: () => _onTypeChanged(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeChip({
    required CategoryIconData typeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? typeIcon.color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? typeIcon.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeIcon.icon,
              color: isSelected ? typeIcon.color : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? typeIcon.color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
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
      child: Column(
        children: [
          _buildCategorySection(),
          _buildDivider(),

          _buildAmountSection(),
          _buildDivider(),

          _buildWalletSection(),
          _buildDivider(),

          _buildDateSection(),
          _buildDivider(),

          _buildNoteSection(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey.shade200);
  }

  Widget _buildCategorySection() {
    final filteredCategories = _allCategories
        .where((cat) => cat.type == _formState.selectedType)
        .toList();

    final selectedCategory = filteredCategories
        .where((c) => c.id == _formState.selectedCategoryId)
        .firstOrNull;

    return _buildCardSection(
      title: 'Category',
      icon: Icons.category_outlined,
      child: selectedCategory == null
          ? _buildCategoryPlaceholder()
          : _buildSelectedCategory(selectedCategory),
    );
  }

  Widget _buildCategoryPlaceholder() {
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

  Widget _buildSelectedCategory(CategoryViewData category) {
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
    final filtered = _allCategories
        .where((c) => c.type == _formState.selectedType)
        .toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Select Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final category = filtered[index];
                  return _buildCategoryPickerItem(category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPickerItem(CategoryViewData category) {
    final isSelected = _formState.selectedCategoryId == category.id;

    return GestureDetector(
      onTap: () {
        _onCategoryChanged(category.id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? category.color
                : category.color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? category.color.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              radius: 18,
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? category.color : Colors.black87,
                ),
              ),
            ),

            if (isSelected)
              Icon(Icons.check_circle, color: category.color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection() {
    return _buildCardSection(
      title: 'Amount',
      icon: Icons.payments_outlined,
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandSeparatorInputFormatter()],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: TextStyle(fontSize: 24, color: Colors.grey.shade300),
          suffixText: ' ₫',
          suffixStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter an amount';
          }
          final amount = int.tryParse(value.replaceAll('.', '')) ?? 0;

          if (amount <= 0) {
            return 'Amount must be greater than 0';
          }
          return null;
        },
        onChanged: (value) {
          _formState = _formState.copyWith(amount: value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
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
    );
  }

  Widget _buildWalletSection() {
    final selectedWallet = _allWallets
        .where((w) => w.id == _formState.selectedWalletId)
        .firstOrNull;
    return _buildCardSection(
      title: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      child: selectedWallet == null
          ? _buildWalletPlaceholder()
          : _buildSelectedWallet(selectedWallet),
    );
  }

  Widget _buildWalletPlaceholder() {
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

  Widget _buildSelectedWallet(WalletViewData wallet) {
    return GestureDetector(
      onTap: _showWalletPicker,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: wallet.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(wallet.icon, color: wallet.color, size: 20),
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
                  CurrencyFormatter.formatVND(wallet.balance),
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Select Wallet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _allWallets.length,
                itemBuilder: (context, index) {
                  final wallet = _allWallets[index];
                  return _buildWalletPickerItem(wallet);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletPickerItem(WalletViewData wallet) {
    final isSelected = _formState.selectedWalletId == wallet.id;

    return GestureDetector(
      onTap: () {
        _onWalletChanged(wallet.id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? wallet.color : wallet.color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? wallet.color.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              radius: 18,
              backgroundColor: wallet.color.withOpacity(0.2),
              child: Icon(wallet.icon, color: wallet.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Name & Balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? wallet.color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatVND(wallet.balance),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: wallet.balance >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(Icons.check_circle, color: wallet.color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return _buildCardSection(
      title: 'Date',
      icon: Icons.calendar_today_outlined,
      child: GestureDetector(
        onTap: _showDatePicker,
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
              DateFormat('dd/MM/yyyy').format(_formState.selectedDate),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _formState.selectedDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _formState.selectedDate) {
      setState(() {
        _formState = _formState.copyWith(selectedDate: picked);
      });
    }
  }

  Widget _buildNoteSection() {
    return _buildCardSection(
      title: 'Note',
      icon: Icons.notes_outlined,
      child: TextFormField(
        controller: _noteController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Add a note (optional)',
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          _formState = _formState.copyWith(note: value);
        },
      ),
    );
  }

  void _onTypeChanged(CategoryType type) {
    final firstCategory = _allCategories
        .where((c) => c.type == type)
        .firstOrNull;
    setState(() {
      _formState = _formState.copyWith(
        selectedType: type,
        selectedCategoryId: firstCategory?.id,
      );
    });
  }

  void _onCategoryChanged(String categoryId) {
    setState(() {
      _formState = _formState.copyWith(selectedCategoryId: categoryId);
    });
  }

  void _onWalletChanged(String walletId) {
    setState(() {
      _formState = _formState.copyWith(selectedWalletId: walletId);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_formState.isValid) return;

    try {
      final transaction = TransactionPayload.fromFormState(_formState);

      await _transactionViewModel.addTransaction(transaction);

      if (mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Transaction added successfully!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorNotification.show(
          context: context,
          message: 'Failed to add transaction: $e',
        );
      }
    }
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/utils/thousand_separator_input_formatter.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../presentation/model/transaction_view_data.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import 'transaction_form_state.dart';
import '../../../categories/domain/category.dart';
import '../../../categories/presentation/constants/category_icons.dart';
import '../../../categories/presentation/helpers/label.dart';
import 'transaction_payload.dart';
import 'category_selector.dart';
import '../widgets/wallet_section.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionViewData transaction;

  const EditTransactionPage({super.key, required this.transaction});

  @override
  State<EditTransactionPage> createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late TransactionsViewModel _transactionViewModel;
  late CategoriesViewModel _categoriesViewModel;
  late WalletsViewModel _walletsViewModel;

  late TransactionFormState _formState;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: _formatAmount(widget.transaction.amount),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );

    _transactionViewModel = getIt<TransactionsViewModel>();
    _categoriesViewModel = getIt<CategoriesViewModel>();
    _walletsViewModel = getIt<WalletsViewModel>();

    _formState = TransactionFormState(
      selectedType: widget.transaction.category.type,
      selectedCategoryId: widget.transaction.category.id,
      selectedWalletId: widget.transaction.wallet.id,
      selectedDate: widget.transaction.transactionDate,
      amount: _formatAmount(widget.transaction.amount),
      note: widget.transaction.note ?? '',
    );
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
      title: 'Edit Transaction',
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
            _buildCategoryTypeSelector(widget.transaction.category.type),
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

  Widget _buildCategoryTypeSelector(CategoryType type) {
    final label = LabelHelper.getCategoryLabel(type);
    final icon = CategoryTypeIcons.typeIcons[type]!;
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
              color: icon.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: icon.color, width: 2),
            ),
            child: Icon(icon.icon, color: icon.color, size: 28),
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
                    color: icon.color,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<List<CategoryViewData>>(
        stream: _categoriesViewModel.categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Text(
              'Error loading categories',
              style: TextStyle(color: Colors.red, fontSize: 14),
            );
          }

          final categories = snapshot.data ?? [];
          final filteredCategories = categories
              .where((cat) => cat.type == _formState.selectedType)
              .toList();

          if (_formState.selectedCategoryId == null &&
              filteredCategories.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onCategoryChanged(filteredCategories.first.id);
            });
          }

          return CategorySelector(
            categories: filteredCategories,
            selectedId: _formState.selectedCategoryId,
            onSelected: _onCategoryChanged,
            showLabel: true,
          );
        },
      ),
    );
  }

  void _onCategoryChanged(String categoryId) {
    setState(() {
      _formState = _formState.copyWith(selectedCategoryId: categoryId);
    });
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
          final amount = _parseAmount(value);
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

  Widget _buildWalletSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<List<WalletViewData>>(
        stream: _walletsViewModel.walletsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Text(
              'Error loading wallets',
              style: TextStyle(color: Colors.red, fontSize: 14),
            );
          }

          final wallets = snapshot.data ?? [];

          // Auto-select first wallet if none selected
          if (_formState.selectedWalletId == null && wallets.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _onWalletChanged(wallets.first.id);
            });
          }

          final selectedWallet = wallets
              .where((wallet) => wallet.id == _formState.selectedWalletId)
              .firstOrNull;

          return WalletSection(
            wallets: wallets,
            selectedWalletId: selectedWallet?.id,
            onSelected: _onWalletChanged,
            showLabel: true,
          );
        },
      ),
    );
  }

  void _onWalletChanged(String walletId) {
    setState(() {
      _formState = _formState.copyWith(selectedWalletId: walletId);
    });
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
    );

    if (picked != null) {
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

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
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
        onPressed: _formState.isValid ? _submitForm : null,
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
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_formState.isValid) return;

    try {
      final transaction = TransactionPayload(
        id: widget.transaction.id,
        categoryId: _formState.selectedCategoryId!,
        walletId: _formState.selectedWalletId!,
        amount: _parseAmount(_formState.amount),
        transactionDate: _formState.selectedDate,
        note: _formState.note.isEmpty ? null : _formState.note,
        createdAt: widget.transaction.createdAt,
        updatedAt: DateTime.now(),
      );

      await _transactionViewModel.updateTransaction(transaction);

      if (mounted) {
        SuccessNotification.show(
          context: context,
          message: 'Transaction updated successfully!',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorNotification.show(
          context: context,
          message: 'Error: $e',
          duration: const Duration(seconds: 10),
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

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  //TODO: REMOVE
  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return formatter.format(amount).replaceAll(',', '.');
  }

  int _parseAmount(String formatted) {
    final cleaned = formatted.replaceAll('.', '').replaceAll(',', '');
    return int.tryParse(cleaned) ?? 0;
  }
}

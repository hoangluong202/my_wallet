import 'package:flutter/material.dart';
import 'package:my_wallet/features/transactions/presentation/form/category_selector.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../categories/domain/category.dart';
import 'transaction_form_state.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import 'transaction_payload.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/amount_section.dart';
import '../widgets/wallet_section.dart';
import '../widgets/wallet_picker_bottom_sheet.dart';
import '../widgets/date_section.dart';
import '../widgets/note_section.dart';
import '../widgets/submit_button.dart';
import '../widgets/form_card_section.dart';

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

      _allCategories = _allCategories.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _allWallets = _allWallets.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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

  List<CategoryViewData> get _filteredCategories {
    return _allCategories
        .where((cat) => cat.type == _formState.selectedType)
        .toList();
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
    return TransactionTypeSelector(
      selectedType: _formState.selectedType,
      onTypeChanged: _onTypeChanged,
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
    return FormCardSection(
      title: 'Category',
      icon: Icons.category_outlined,
      child: CategorySelector(
        categories: _filteredCategories,
        selectedId: _formState.selectedCategoryId,
        onSelected: (id) {
          setState(() {
            _formState = _formState.copyWith(selectedCategoryId: id);
          });
        },
      ),
    );
  }

  Widget _buildAmountSection() {
    return FormCardSection(
      title: 'Amount',
      icon: Icons.payments_outlined,
      child: AmountSection(
        controller: _amountController,
        onChanged: (value) {
          _formState = _formState.copyWith(amount: value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SubmitButton(onPressed: _submitForm);
  }

  Widget _buildWalletSection() {
    final selectedWallet = _allWallets
        .where((w) => w.id == _formState.selectedWalletId)
        .firstOrNull;
    return FormCardSection(
      title: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      child: WalletSection(
        selectedWallet: selectedWallet,
        onTap: _showWalletPicker,
      ),
    );
  }

  void _showWalletPicker() {
    WalletPickerBottomSheet.show(
      context: context,
      wallets: _allWallets,
      selectedWalletId: _formState.selectedWalletId,
      onWalletSelected: _onWalletChanged,
    );
  }

  Widget _buildDateSection() {
    return FormCardSection(
      title: 'Date',
      icon: Icons.calendar_today_outlined,
      child: DateSection(
        selectedDate: _formState.selectedDate,
        onDateChanged: (date) {
          setState(() {
            _formState = _formState.copyWith(selectedDate: date);
          });
        },
      ),
    );
  }

  Widget _buildNoteSection() {
    return FormCardSection(
      title: 'Note',
      icon: Icons.notes_outlined,
      child: NoteSection(
        controller: _noteController,
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
}

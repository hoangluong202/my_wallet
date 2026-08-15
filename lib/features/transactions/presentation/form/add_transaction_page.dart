import 'package:flutter/material.dart';
import 'package:my_wallet/features/transactions/presentation/form/category_selector.dart';
import '../../../../core/widgets/header/detail_header.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/di/injector.dart';
import '../viewmodel/transactions_viewmodel.dart';
import '../../../categories/presentation/list/categories_viewmodel.dart';
import '../../../wallets/presentation/list/wallets_viewmodel.dart';
import '../../../categories/domain/category.dart';
import '../controllers/add_transaction_controller.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/amount_section.dart';
import '../widgets/wallet_section.dart';
import '../widgets/wallet_picker_bottom_sheet.dart';
import '../widgets/date_section.dart';
import '../widgets/note_section.dart';
import '../widgets/submit_button.dart';
import '../widgets/form_card_section.dart';
import '../constants/form_constants.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late AddTransactionController _controller;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController();
    _noteController = TextEditingController();

    _controller = AddTransactionController(
      transactionViewModel: getIt<TransactionsViewModel>(),
      categoriesViewModel: getIt<CategoriesViewModel>(),
      walletsViewModel: getIt<WalletsViewModel>(),
    );

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      await _controller.loadInitialData();
      setState(() {});
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _controller.dispose();
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
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return DetailHeader(
      title: FormConstants.pageTitle,
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: FormConstants.formHorizontalPadding,
        vertical: FormConstants.formVerticalPadding,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryTypeSelector(),
            const SizedBox(height: FormConstants.sectionSpacing),
            _buildFormCard(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: FormConstants.buttonBottomSpacing),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTypeSelector() {
    return TransactionTypeSelector(
      selectedType: _controller.formState.selectedType,
      onTypeChanged: _onTypeChanged,
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FormConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(FormConstants.cardShadowOpacity),
            blurRadius: FormConstants.cardShadowBlurRadius,
            offset: const Offset(0, FormConstants.cardElevation),
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
      child: CategorySelector(
        categories: _controller.filteredCategories,
        selectedId: _controller.formState.selectedCategoryId,
        onSelected: _onCategorySelected,
        showLabel: true,
      ),
    );
  }

  Widget _buildAmountSection() {
    return FormCardSection(
      title: FormConstants.amountLabel,
      icon: Icons.payments_outlined,
      child: AmountSection(
        controller: _amountController,
        onChanged: (value) {
          _controller.updateAmount(value);
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SubmitButton(
      onPressed: _submitForm,
      label: _controller.isSubmitting
          ? FormConstants.savingButtonLabel
          : FormConstants.saveButtonLabel,
    );
  }

  Widget _buildWalletSection() {
    return FormCardSection(
      title: FormConstants.walletLabel,
      icon: Icons.account_balance_wallet_outlined,
      child: WalletSection(
        selectedWallet: _controller.selectedWallet,
        onTap: _showWalletPicker,
      ),
    );
  }

  void _showWalletPicker() {
    WalletPickerBottomSheet.show(
      context: context,
      wallets: _controller.allWallets,
      selectedWalletId: _controller.formState.selectedWalletId,
      onWalletSelected: _onWalletChanged,
    );
  }

  Widget _buildDateSection() {
    return FormCardSection(
      title: FormConstants.dateLabel,
      icon: Icons.calendar_today_outlined,
      child: DateSection(
        selectedDate: _controller.formState.selectedDate,
        onDateChanged: _onDateChanged,
      ),
    );
  }

  Widget _buildNoteSection() {
    return FormCardSection(
      title: FormConstants.noteLabel,
      icon: Icons.notes_outlined,
      child: NoteSection(
        controller: _noteController,
        onChanged: _controller.updateNote,
      ),
    );
  }

  // Event handlers
  void _onCategorySelected(String categoryId) {
    setState(() {
      _controller.updateSelectedCategory(categoryId);
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _controller.updateSelectedDate(date);
    });
  }

  void _onTypeChanged(CategoryType type) {
    setState(() {
      _controller.updateTransactionType(type);
    });
  }

  void _onWalletChanged(String walletId) {
    setState(() {
      _controller.updateSelectedWallet(walletId);
    });
  }

  Future<void> _submitForm() async {
    // Prevent double submission
    if (_controller.isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;
    if (!_controller.validateForm()) return;

    try {
      await _controller.submitTransaction();

      if (mounted) {
        SuccessNotification.show(
          context: context,
          message: FormConstants.successMessage,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ErrorNotification.show(
          context: context,
          message: '${FormConstants.errorMessagePrefix}: $e',
        );
      }
    } finally {
      if (mounted) setState(() {});
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'wallet_form_viewmodel.dart';
import '../../../../core/widgets/header/detail_header.dart';
import 'wallet_icon_selector.dart';
import '../model/wallet_view_data.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../data/repositories/wallet_repository.dart';

class AddWalletPage extends StatelessWidget {
  const AddWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletFormPage(isEditMode: false);
  }
}

class EditWalletPage extends StatelessWidget {
  final WalletViewData wallet;

  const EditWalletPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return WalletFormPage(wallet: wallet, isEditMode: true);
  }
}

class WalletFormPage extends StatefulWidget {
  final WalletViewData? wallet;
  final bool isEditMode;

  const WalletFormPage({super.key, this.wallet, this.isEditMode = false});

  @override
  State<WalletFormPage> createState() => _WalletFormPageState();
}

class _WalletFormPageState extends State<WalletFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final WalletFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    final repository = GetIt.instance<WalletRepository>();

    _viewModel = WalletFormViewModel(
      repository: repository,
      isEditMode: widget.isEditMode,
      existingWallet: widget.wallet,
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
            DetailHeader(
              title: widget.isEditMode ? 'Edit Wallet' : 'Add Wallet',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(child: _buildForm()),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Form(
        key: _formKey,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconSelectorCard(),
                const SizedBox(height: 16),
                _buildFormCard(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconSelectorCard() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Wallet Icon & Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WalletIconSelector(
            selectedIcon: _viewModel.selectedIcon,
            selectedIconColor: _viewModel.selectedIconColor,
            onIconSelected: _viewModel.selectIcon,
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
          // Wallet Name Section
          _buildCardSection(
            title: 'Wallet Name',
            icon: Icons.account_balance_wallet_outlined,
            child: TextFormField(
              controller: _viewModel.nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Savings, Momo, Main Account',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              validator: _viewModel.validateName,
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),

          // Balance Section
          _buildCardSection(
            title: widget.isEditMode ? 'Current Balance' : 'Initial Balance',
            icon: Icons.payments_outlined,
            child: TextFormField(
              controller: _viewModel.balanceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _viewModel.formatBalance,
              decoration: InputDecoration(
                hintText: '1.000.000',
                hintStyle: TextStyle(fontSize: 20, color: Colors.grey.shade300),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12.0, top: 12),
                  child: Text(
                    'đ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 0),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              validator: _viewModel.validateBalance,
            ),
          ),
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
        child: Text(
          widget.isEditMode ? 'Update Wallet' : 'Create Wallet',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final success = widget.isEditMode
        ? await _viewModel.updateWallet()
        : await _viewModel.createWallet();

    if (!mounted) return;

    if (success) {
      // Show success notification
      SuccessNotification.show(
        context: context,
        message: widget.isEditMode
            ? 'Wallet updated successfully!'
            : 'Wallet created successfully!',
      );
      Navigator.pop(context, true);
    } else {
      ErrorNotification.show(
        context: context,
        message: _viewModel.errorMessage ?? 'Something went wrong',
      );
    }
  }
}

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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Form(
        key: _formKey,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWalletPreview(),
                const SizedBox(height: 20),
                _buildIconSelectorCard(),
                const SizedBox(height: 12),
                _buildFormCard(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWalletPreview() {
    final color = _viewModel.selectedIconColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.65)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Icon(_viewModel.selectedIcon, color: Colors.white, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _viewModel.nameController,
              builder: (context, value, _) {
                final name = value.text.trim();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isEditMode ? 'Wallet preview' : 'New wallet',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name.isEmpty ? 'Wallet name' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VND',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelectorCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Choose a style',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet information',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Wallet name',
            icon: Icons.account_balance_wallet_outlined,
            controller: _viewModel.nameController,
            hintText: 'e.g. Savings, Momo, Main Account',
            validator: _viewModel.validateName,
          ),
          const SizedBox(height: 14),
          _buildField(
            title: widget.isEditMode ? 'Current Balance' : 'Initial Balance',
            icon: Icons.payments_outlined,
            controller: _viewModel.balanceController,
            hintText: '1.000.000',
            suffixText: '₫',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _viewModel.formatBalance,
            validator: _viewModel.validateBalance,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    String? title,
    String? label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    String? suffixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? title!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, size: 20),
            suffixText: suffixText,
            suffixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _viewModel.selectedIconColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _viewModel.selectedIconColor.withValues(alpha: 0.9),
            _viewModel.selectedIconColor.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _viewModel.selectedIconColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _viewModel.isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _viewModel.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                widget.isEditMode ? 'Update Wallet' : 'Create Wallet',
                style: const TextStyle(
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/wallet.dart';
import '../viewmodels/wallet_form_viewmodel.dart';
import '../../../../shared/widgets/header/detail_header.dart';
import '../widgets/wallet_icon_selector.dart';
import '../../../../shared/widgets/form/custom_text_field.dart';

class WalletFormPage extends StatefulWidget {
  final Wallet? wallet;
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
    _viewModel = WalletFormViewModel(
      isEditMode: widget.isEditMode,
      existingWallet: widget.wallet,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final walletData = _viewModel.getWalletData();

      debugPrint(
        'Wallet ${widget.isEditMode ? 'updated' : 'created'}: $walletData',
      );

      Navigator.pop(context, walletData);
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
              title: widget.isEditMode ? 'Edit Wallet' : 'Add Wallet',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WalletIconSelector(
                              selectedIcon: _viewModel.selectedIcon,
                              selectedIconColor: _viewModel.selectedIconColor,
                              onIconSelected: _viewModel.selectIcon,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              controller: _viewModel.nameController,
                              label: 'Wallet Name',
                              hintText: 'e.g., Savings, Momo, Main Account',
                              validator: _viewModel.validateName,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _viewModel.balanceController,
                              label: widget.isEditMode
                                  ? 'Current Balance'
                                  : 'Initial Balance',
                              hintText: '1.000.000',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: _viewModel.formatBalance,
                              validator: _viewModel.validateBalance,
                              suffixText: 'đ',
                              suffixStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitForm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(widget.isEditMode ? 'Update Wallet' : 'Create Wallet'),
          ),
        ),
      ),
    );
  }
}

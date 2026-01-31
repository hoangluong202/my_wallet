import 'package:flutter/material.dart';
import 'package:my_wallet/core/utils/thousand_separator_input_formatter.dart';
import 'package:my_wallet/core/widgets/base_detail_page.dart';
import 'package:my_wallet/core/widgets/form/card_section.dart';
import 'package:my_wallet/core/widgets/header/detail_header.dart';
import 'package:my_wallet/features/wallets/presentation/form/transfer_money_viewmodel.dart';
import 'package:my_wallet/features/wallets/presentation/model/wallet_view_data.dart';
import '../../../../core/widgets/form/submit_button.dart';
import '../../../../core/widgets/form/wallet_selector.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/notification_widget.dart';

class TransferMoneyPage extends StatefulWidget {
  final WalletViewData sourceWallet;

  const TransferMoneyPage({super.key, required this.sourceWallet});

  @override
  State<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends State<TransferMoneyPage> {
  late TransferMoneyViewModel _transferMoneyViewModel;
  @override
  void initState() {
    super.initState();
    _transferMoneyViewModel = getIt<TransferMoneyViewModel>();
    _transferMoneyViewModel.loadAvailableWallets(widget.sourceWallet.id);
  }

  @override
  Widget build(BuildContext context) {
    return BaseDetailPage(
      header: _buildHeader(),
      body: _buildBody(),
      footer: _buildFooter(),
    );
  }

  Widget _buildHeader() {
    return DetailHeader(
      title: 'Transfer Money',
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildBody() {
    return ListenableBuilder(
      listenable: _transferMoneyViewModel,
      builder: (context, child) {
        if (_transferMoneyViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildConstSourceWallet(),
              _buildAmountSection(),
              _buildWalletSelector(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConstSourceWallet() {
    return WalletSelector(
      wallets: [widget.sourceWallet],
      selectedWalletId: widget.sourceWallet.id,
      onWalletSelected: (_) {},
      title: 'Source Wallet',
    );
  }

  Widget _buildAmountSection() {
    return CardSection(
      title: 'Amount',
      icon: Icons.payments_outlined,
      child: TextFormField(
        controller: _transferMoneyViewModel.amountController,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandSeparatorInputFormatter()],
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: '0',
          hintStyle: TextStyle(fontSize: 24, color: Colors.grey.shade300),
          suffixText: ' ₫',
          suffixStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorText: _transferMoneyViewModel.errorAmount,
        ),
        onChanged: _transferMoneyViewModel.validateAmount,
      ),
    );
  }

  Widget _buildWalletSelector() {
    return WalletSelector(
      wallets: _transferMoneyViewModel.availableWallets
          .map((w) => WalletViewData.fromDomain(w))
          .toList(),
      selectedWalletId: _transferMoneyViewModel.targetWalletId,
      onWalletSelected: (walletId) {
        _transferMoneyViewModel.onTargetWalletSelected(walletId);
      },
      title: 'Select Target Wallet',
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SubmitButton(
        label: 'Transfer Money',
        onPressed: () => _submitForm(context),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    try {
      await _transferMoneyViewModel.transferMoney(
        sourceWalletId: widget.sourceWallet.id,
      );

      if (!context.mounted) return;

      SuccessNotification.show(
        context: context,
        message:
            _transferMoneyViewModel.successMessage ??
            'Transfer completed successfully',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!context.mounted) return;

      ErrorNotification.show(
        context: context,
        message:
            _transferMoneyViewModel.errorTo ??
            'Failed to transfer amount. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _transferMoneyViewModel.dispose();
    super.dispose();
  }
}

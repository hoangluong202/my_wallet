import 'package:flutter/material.dart';
import '../../domain/wallet.dart';
import 'wallet_form_page.dart';

class EditWalletPage extends StatelessWidget {
  final Wallet wallet;

  const EditWalletPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return WalletFormPage(wallet: wallet, isEditMode: true);
  }
}

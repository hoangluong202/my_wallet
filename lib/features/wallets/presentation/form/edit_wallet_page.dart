import 'package:flutter/material.dart';
import 'wallet_form_page.dart';
import '../model/wallet_view_data.dart';

class EditWalletPage extends StatelessWidget {
  final WalletViewData wallet;

  const EditWalletPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return WalletFormPage(wallet: wallet, isEditMode: true);
  }
}

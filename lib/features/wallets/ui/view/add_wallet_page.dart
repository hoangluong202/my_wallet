import 'package:flutter/material.dart';
import 'wallet_form_page.dart';

class AddWalletPage extends StatelessWidget {
  const AddWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WalletFormPage(isEditMode: false);
  }
}

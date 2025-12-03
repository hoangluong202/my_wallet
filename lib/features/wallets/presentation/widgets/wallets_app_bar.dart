import 'package:flutter/material.dart';
import '../../../../core/widgets/page_header.dart';

class WalletsAppBar extends StatelessWidget {
  final VoidCallback onAddPressed;

  const WalletsAppBar({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: 'Wallets',
      subtitle: 'Manage your wallets',
      icon: Icons.account_balance_wallet_outlined,
      onActionPressed: onAddPressed,
      actionIcon: Icons.add,
    );
  }
}

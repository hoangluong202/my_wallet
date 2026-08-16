import 'package:flutter/material.dart';
import '../model/wallet_view_data.dart';

class WalletIconSection extends StatelessWidget {
  final WalletViewData wallet;

  const WalletIconSection({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: wallet.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(wallet.icon, size: 28, color: wallet.color),
          ),
          const SizedBox(height: 8),
          Text(
            wallet.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

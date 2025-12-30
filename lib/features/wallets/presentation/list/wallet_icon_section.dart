import 'package:flutter/material.dart';
import '../../domain/wallet.dart';
import '../constants/wallet_icons.dart';

class WalletIconSection extends StatelessWidget {
  final Wallet wallet;

  const WalletIconSection({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final iconData = WalletIcons.getIconByCodePoint(wallet.iconCode);

    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconData.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData.icon, size: 28, color: iconData.color),
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

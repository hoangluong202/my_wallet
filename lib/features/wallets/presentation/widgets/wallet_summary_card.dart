import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class WalletSummaryCard extends StatelessWidget {
  final int walletsCount;
  final double totalBalance;

  const WalletSummaryCard({
    super.key,
    required this.walletsCount,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text('$walletsCount wallets'),
            ],
          ),
          Text(
            CurrencyFormatter.formatVNDWithSymbol(totalBalance),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: totalBalance < 0 ? Colors.red : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

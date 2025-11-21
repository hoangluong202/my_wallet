import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/wallet.dart';

class WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;

  const WalletCard({super.key, required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildWalletInfo()),
              const SizedBox(width: 10),
              _buildBalance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: wallet.iconColor.withOpacity(0.2),
      child: Icon(wallet.icon, size: 20, color: wallet.iconColor),
    );
  }

  Widget _buildWalletInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wallet.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          'Created on ${DateFormatter.formatDate(wallet.createdOn)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          'Last updated ${DateFormatter.formatDuration(wallet.lastUpdated)}',
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBalance() {
    return Text(
      CurrencyFormatter.formatVNDWithSymbol(wallet.balance),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: wallet.balance < 0 ? Colors.red : Colors.green.shade700,
      ),
    );
  }
}

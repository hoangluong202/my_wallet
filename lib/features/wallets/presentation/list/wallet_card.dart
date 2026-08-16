import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../model/wallet_view_data.dart';

class WalletCard extends StatelessWidget {
  final WalletViewData wallet;
  final VoidCallback onTap;

  const WalletCard({super.key, required this.wallet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 11),
                Expanded(child: _buildWalletInfo()),
                const SizedBox(width: 8),
                SizedBox(
                  width: 112,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildBalance(),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      decoration: BoxDecoration(
        color: wallet.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(9),
      child: Icon(wallet.icon, color: wallet.color, size: 22),
    );
  }

  Widget _buildWalletInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wallet.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatDateTime(wallet.updatedAt),
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBalance() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        CurrencyFormatter.formatVNDWithSymbol(wallet.balance),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: wallet.balance < 0 ? Colors.red : Colors.green.shade700,
        ),
      ),
    );
  }
}

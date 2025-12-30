import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/wallet.dart';
import '../constants/wallet_icons.dart';

class WalletInfoCard extends StatelessWidget {
  final Wallet wallet;

  const WalletInfoCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final iconData = WalletIcons.getIconByCodePoint(wallet.iconCode);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconData.color.withValues(alpha: 0.8),
            iconData.color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: iconData.color.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceSection(),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 12),
          _buildDetailsSection(),
        ],
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Balance',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatVNDWithSymbol(wallet.balance),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildDetailsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            label: 'Created On',
            value: DateFormatter.formatDate(wallet.createdAt),
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            label: 'Last Updated',
            value: DateFormatter.formatDuration(wallet.updatedAt),
          ),
        ),
        Expanded(
          child: _buildDetailItem(label: 'Currency', value: 'VND (₫)'),
        ),
      ],
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

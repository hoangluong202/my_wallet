import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';

class TransactionsSummaryCard extends StatelessWidget {
  const TransactionsSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.wallets,
  });

  final int totalIncome;
  final int totalExpense;
  final List<WalletViewData> wallets;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final difference = totalIncome - totalExpense;
    final balanceColor = difference >= 0
        ? const Color(0xFF17875B)
        : const Color(0xFFD84949);
    final recentWallets = List<WalletViewData>.from(wallets)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final displayedWallets = recentWallets.take(2).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Net balance',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _signedCurrency(difference),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: balanceColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Income',
                  amount: totalIncome,
                  prefix: '+',
                  icon: Icons.south_west_rounded,
                  color: const Color(0xFF17875B),
                ),
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
              Expanded(
                child: _SummaryItem(
                  label: 'Expenses',
                  amount: totalExpense,
                  prefix: '-',
                  icon: Icons.north_east_rounded,
                  color: const Color(0xFFD84949),
                ),
              ),
            ],
          ),
          if (displayedWallets.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Divider(
                height: 1,
                color: colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
            Row(
              children: [
                for (
                  var index = 0;
                  index < displayedWallets.length;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _WalletBalanceItem(wallet: displayedWallets[index]),
                  ),
                ],
                if (displayedWallets.length == 1) const Spacer(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _signedCurrency(int amount) {
    final formatted = CurrencyFormatter.formatVNDWithSymbol(amount.abs());
    if (amount > 0) return '+$formatted';
    if (amount < 0) return '-$formatted';
    return formatted;
  }
}

class _WalletBalanceItem extends StatelessWidget {
  const _WalletBalanceItem({required this.wallet});

  final WalletViewData wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: wallet.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(wallet.icon, size: 17, color: wallet.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wallet.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                CurrencyFormatter.formatVNDWithSymbol(wallet.balance),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: wallet.balance >= 0
                      ? colors.onSurface
                      : const Color(0xFFD84949),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.prefix,
    required this.icon,
    required this.color,
  });

  final String label;
  final int amount;
  final String prefix;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '$prefix${CurrencyFormatter.formatVNDWithSymbol(amount.abs())}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

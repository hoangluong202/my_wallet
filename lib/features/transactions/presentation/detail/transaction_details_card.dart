import 'package:flutter/material.dart';
import '../model/transaction_view_data.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../constants/transaction_type.dart';

class TransactionDetailsCard extends StatelessWidget {
  final TransactionViewData transaction;

  const TransactionDetailsCard(this.transaction, {super.key});

  static const double _iconSize = 64.0;
  static const double _iconInnerSize = 54.0;
  static const double _spacing = 16.0;
  static const double _padding = 20.0;
  static const double _borderRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    final style = TransactionTypeConstants.getStyle(transaction.category.type);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: _spacing, vertical: 12),
      child: _buildCard(context, style),
    );
  }

  Widget _buildCard(BuildContext context, TransactionTypeStyle style) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [_buildHeader(style), _buildDetails()]),
    );
  }

  Widget _buildHeader(TransactionTypeStyle style) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.amountColor.withOpacity(0.1),
            style.amountColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(_borderRadius),
          topRight: Radius.circular(_borderRadius),
        ),
      ),
      child: Row(
        children: [
          _buildIconSection(style),
          const SizedBox(width: _spacing),
          Expanded(child: _buildAmountSection(style)),
        ],
      ),
    );
  }

  Widget _buildIconSection(TransactionTypeStyle style) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background circle
        Container(
          width: _iconSize,
          height: _iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: style.amountColor.withOpacity(0.15),
          ),
        ),
        // Icon container
        Container(
          width: _iconInnerSize,
          height: _iconInnerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: style.amountColor.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            transaction.category.icon,
            color: style.amountColor,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection(TransactionTypeStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [style.amountColor, style.amountColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: style.amountColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            style.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Amount
        Text(
          '${style.amountPrefix}${CurrencyFormatter.formatVND(transaction.amount)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: style.amountColor,
            letterSpacing: -0.5,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // Currency
        Text(
          'VND',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: style.amountColor.withOpacity(0.7),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.category_outlined,
            label: 'Category',
            value: transaction.category.name,
            iconColor: Colors.purple,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: DateFormatter.formatDate(transaction.transactionDate),
            iconColor: Colors.blue,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            value: transaction.wallet.name,
            iconColor: Colors.orange,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.notes_outlined,
            label: 'Note',
            value: transaction.note ?? 'No note',
            iconColor: Colors.teal,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

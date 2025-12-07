import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_item.dart';

class TransactionItemCard extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback onTap;

  const TransactionItemCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors and display based on transaction type
    final Color amountColor;
    final Color bgColor;
    final String typeLabel;
    final String amountPrefix;

    switch (transaction.type) {
      case TransactionType.income:
        amountColor = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        typeLabel = 'Income';
        amountPrefix = '+';
        break;
      case TransactionType.expense:
        amountColor = Colors.red;
        bgColor = Colors.red.shade50;
        typeLabel = 'Expense';
        amountPrefix = '-';
        break;
      case TransactionType.debt:
        amountColor = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        typeLabel = 'Debt';
        amountPrefix = '+';
        break;
      case TransactionType.loan:
        amountColor = Colors.purple.shade700;
        bgColor = Colors.purple.shade50;
        typeLabel = 'Loan';
        amountPrefix = '-';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Leading Icon
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  transaction.categoryIcon,
                  color: amountColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount and Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${CurrencyFormatter.formatVNDWithSymbol(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Arrow Icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

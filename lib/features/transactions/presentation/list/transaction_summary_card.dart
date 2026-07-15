import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class TransactionsSummaryCard extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;

  const TransactionsSummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cột Thu nhập
          Expanded(
            child: _buildSummaryItem(
              title: "Thu nhập",
              amount: totalIncome,
              color: Colors.green.shade600,
              icon: Icons.arrow_downward_rounded,
            ),
          ),

          // Vạch chia giữa 2 cột thanh mảnh
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),

          // Cột Chi tiêu
          Expanded(
            child: _buildSummaryItem(
              title: "Chi tiêu",
              amount: totalExpense,
              color: Colors.red.shade600,
              icon: Icons.arrow_upward_rounded,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildSummaryItem({
    required String title,
    required int amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: color.withOpacity(0.9), // Icon rõ ràng
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: color.withOpacity(0.75),
                fontSize: 12,
                fontWeight: FontWeight.w600, // Tăng độ đậm nét chữ lên một chút
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        Text(
          CurrencyFormatter.formatVNDWithSymbol(amount),
          style: TextStyle(
            color: color, // Màu đậm 100%
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}

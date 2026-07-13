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
    final balance = totalIncome - totalExpense;
    final isPositive = balance >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Đảm bảo Column thu gọn theo nội dung
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context: context,
                      title: "Thu nhập",
                      amount: totalIncome,
                      color: Colors.green.shade600,
                      icon: Icons.arrow_downward_rounded,
                      iconBg: Colors.green.shade50,
                    ),
                  ),

                  Container(height: 36, width: 1, color: Colors.grey.shade200),

                  Expanded(
                    child: _buildSummaryItem(
                      context: context,
                      title: "Chi tiêu",
                      amount: totalExpense,
                      color: Colors.red.shade600,
                      icon: Icons.arrow_upward_rounded,
                      iconBg: Colors.red.shade50,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required String title,
    required int amount,
    required Color color,
    required IconData icon,
    required Color iconBg,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),

        // Vì Row này nằm trong Expanded bên trên, nên bọc Expanded ở đây là hoàn toàn hợp lệ và chuẩn xác
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 2),
              // SỬA TẠI ĐÂY: Xóa Flexible bên trong Column này đi
              Text(
                CurrencyFormatter.formatVNDWithSymbol(amount),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

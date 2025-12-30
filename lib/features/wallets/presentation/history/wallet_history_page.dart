import 'package:flutter/material.dart';
import '../../domain/wallet.dart';
import '../constants/wallet_icons.dart';

class WalletHistoryPage extends StatelessWidget {
  final Wallet wallet;

  const WalletHistoryPage({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final historyEntries = _getHistoryData();
    final iconData = WalletIcons.getIconByCodePoint(wallet.iconCode);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${wallet.name} History',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatVND(wallet.balance.toInt()),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconData.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(iconData.icon, size: 18, color: iconData.color),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: ListView.separated(
                  itemCount: historyEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) =>
                      _buildHistoryTile(context, historyEntries[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, HistoryEntry entry) {
    final isBalanceUpdate = entry.type == 'Balance Updated';
    final oldInt = _parseVND(entry.oldValue);
    final newInt = _parseVND(entry.newValue);
    final int? delta = (isBalanceUpdate && oldInt != null && newInt != null)
        ? newInt - oldInt
        : null;

    IconData leadingIcon;
    Color leadingColor;
    if (isBalanceUpdate) {
      if (delta == null || delta == 0) {
        leadingIcon = Icons.swap_horiz;
        leadingColor = Colors.blueGrey;
      } else if (delta > 0) {
        leadingIcon = Icons.arrow_upward;
        leadingColor = Colors.green;
      } else {
        leadingIcon = Icons.arrow_downward;
        leadingColor = Colors.red;
      }
    } else if (entry.type == 'Name Changed') {
      leadingIcon = Icons.edit;
      leadingColor = Colors.orange;
    } else {
      leadingIcon = Icons.tune;
      leadingColor = Colors.purple;
    }

    final newBalanceText = newInt != null
        ? '${_formatVND(newInt)} đ'
        : entry.newValue;
    final deltaText = delta != null
        ? '${delta >= 0 ? '+' : '-'}${_formatVND(delta.abs())}'
        : null;
    final deltaColor = delta != null
        ? (delta >= 0 ? Colors.green : Colors.red)
        : Colors.grey;

    // Format date and time
    final dateTime = entry.dateTime;
    final today = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateLabel;
    if (entryDate == todayDate) {
      dateLabel = 'Today';
    } else if (entryDate == yesterdayDate) {
      dateLabel = 'Yesterday';
    } else {
      dateLabel = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: leadingColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(leadingIcon, size: 14, color: leadingColor),
          ),
          const SizedBox(width: 10),
          // Info text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.type,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (entry.notes != null && entry.notes!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.notes!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Balance info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                newBalanceText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (deltaText != null)
                Text(
                  deltaText,
                  style: TextStyle(
                    fontSize: 10,
                    color: deltaColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<HistoryEntry> _getHistoryData() {
    final now = DateTime.now();
    return [
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(hours: 2)),
        oldValue: '5.200.000',
        newValue: '5.230.000',
        notes: 'Deposit from salary',
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 1)),
        oldValue: '5.450.000',
        newValue: '5.200.000',
        notes: 'Withdrawal for bills',
      ),
      HistoryEntry(
        type: 'Name Changed',
        status: 'Rename',
        dateTime: now.subtract(const Duration(days: 3)),
        oldValue: 'Main Account',
        newValue: 'Main Bank Account',
        notes: null,
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 5)),
        oldValue: '3.200.000',
        newValue: '5.450.000',
        notes: 'Transfer from savings',
      ),
      HistoryEntry(
        type: 'Wallet Created',
        status: 'Create',
        dateTime: now.subtract(const Duration(days: 7)),
        oldValue: '0',
        newValue: '3.200.000',
        notes: 'Initial deposit',
      ),
    ];
  }

  // Helpers
  int? _parseVND(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  String _formatVND(int amount) {
    final s = amount.toString();
    final re = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(re, (m) => '.');
  }
}

class HistoryEntry {
  final String type;
  final String status;
  final DateTime dateTime;
  final String oldValue;
  final String newValue;
  final String? notes;

  HistoryEntry({
    required this.type,
    required this.status,
    required this.dateTime,
    required this.oldValue,
    required this.newValue,
    this.notes,
  });
}

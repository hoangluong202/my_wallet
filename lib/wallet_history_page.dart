import 'package:flutter/material.dart';

class WalletHistoryPage extends StatelessWidget {
  final String walletName;
  final double balance;
  final String currency;
  final IconData? icon;
  final Color? iconColor;

  const WalletHistoryPage({
    super.key,
    required this.walletName,
    this.balance = 0.0,
    this.currency = 'VND (₫)',
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final historyEntries = _getHistoryData();

    return Scaffold(
      appBar: AppBar(
        title: Text('$walletName History'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact header with icon, name, and current balance (VND only)
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: (iconColor ?? Colors.blue).withOpacity(0.15),
                  child: Icon(
                    icon ?? Icons.account_balance_wallet,
                    size: 20,
                    color: iconColor ?? Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walletName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatVND(balance.toInt()),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'History',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: historyEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) =>
                    _buildHistoryTile(context, historyEntries[index]),
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

    final newBalanceText = newInt != null ? _formatVND(newInt) : entry.newValue;
    final deltaText = delta != null
        ? '${delta >= 0 ? '+' : '-'}${_formatVND(delta.abs())}'
        : null;
    final deltaColor = delta != null
        ? (delta >= 0 ? Colors.green : Colors.red)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: leadingColor.withOpacity(0.15),
            child: Icon(leadingIcon, size: 18, color: leadingColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.type,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          entry.type,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        entry.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(entry.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.dateTime.toString().split('.')[0]}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.notes != null && entry.notes!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                newBalanceText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (deltaText != null)
                Text(
                  deltaText,
                  style: TextStyle(
                    fontSize: 11,
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

  Color _getStatusColor(String type) {
    switch (type) {
      case 'Balance Updated':
        return Colors.blue;
      case 'Name Changed':
        return Colors.orange;
      case 'Currency Changed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  List<HistoryEntry> _getHistoryData() {
    final now = DateTime.now();
    return [
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(hours: 2)),
        oldValue: '5,200,000đ',
        newValue: '5,230,000đ',
        notes: 'Deposit from salary',
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 1)),
        oldValue: '5,450,000đ',
        newValue: '5,200,000đ',
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
        oldValue: '3,200,000đ',
        newValue: '5,450,000đ',
        notes: 'Transfer from savings',
      ),
      HistoryEntry(
        type: 'Balance Updated',
        status: 'Update',
        dateTime: now.subtract(const Duration(days: 7)),
        oldValue: '5,000,000đ',
        newValue: '3,200,000đ',
        notes: 'Shopping expenses',
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
    final withSep = s.replaceAllMapped(re, (m) => ',');
    return '${withSep}đ';
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

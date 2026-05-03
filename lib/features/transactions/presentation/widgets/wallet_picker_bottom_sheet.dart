import 'package:flutter/material.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import '../../../../core/utils/currency_formatter.dart';

class WalletPickerBottomSheet extends StatelessWidget {
  final List<WalletViewData> wallets;
  final String? selectedWalletId;
  final ValueChanged<String> onWalletSelected;

  const WalletPickerBottomSheet({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.onWalletSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required List<WalletViewData> wallets,
    required String? selectedWalletId,
    required ValueChanged<String> onWalletSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WalletPickerBottomSheet(
        wallets: wallets,
        selectedWalletId: selectedWalletId,
        onWalletSelected: onWalletSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Select Wallet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // List
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return _WalletPickerItem(
                  wallet: wallet,
                  isSelected: selectedWalletId == wallet.id,
                  onTap: () {
                    onWalletSelected(wallet.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletPickerItem extends StatelessWidget {
  final WalletViewData wallet;
  final bool isSelected;
  final VoidCallback onTap;

  const _WalletPickerItem({
    required this.wallet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? wallet.color : wallet.color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? wallet.color.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              radius: 18,
              backgroundColor: wallet.color.withOpacity(0.2),
              child: Icon(wallet.icon, color: wallet.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Name & Balance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? wallet.color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatVND(wallet.balance),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: wallet.balance >= 0
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(Icons.check_circle, color: wallet.color, size: 24),
          ],
        ),
      ),
    );
  }
}

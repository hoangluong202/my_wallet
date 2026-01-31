import 'package:flutter/material.dart';
import 'package:my_wallet/core/widgets/form/card_section.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../features/wallets/presentation/model/wallet_view_data.dart';

class WalletSelector extends StatelessWidget {
  final List<WalletViewData> wallets;
  final String? selectedWalletId;
  final Function(String) onWalletSelected;
  final String title;
  final bool showBalance;
  final EdgeInsets? padding;

  const WalletSelector({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    required this.onWalletSelected,
    this.title = 'Wallet',
    this.showBalance = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final selectedWallet = wallets.firstWhere(
      (w) => w.id == selectedWalletId,
      orElse: () => WalletViewData.empty(),
    );

    final isSelected = selectedWallet.id.isNotEmpty;

    return CardSection(
      title: title,
      icon: Icons.account_balance_wallet_outlined,
      child: GestureDetector(
        onTap: () => _showWalletPicker(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isSelected && selectedWallet != WalletViewData.empty()
              ? _buildSelectedWalletContent(selectedWallet)
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.add, color: Colors.grey.shade500, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Choose a wallet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildSelectedWalletContent(WalletViewData wallet) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: wallet.color.withValues(alpha: 0.15),
          child: Icon(wallet.icon, color: wallet.color, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wallet.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (showBalance) ...[
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.formatVND(wallet.balance),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: wallet.balance >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  void _showWalletPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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

                  Text(
                    'Choose a wallet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        final wallet = wallets[index];
                        final isSelected = selectedWalletId == wallet.id;

                        return GestureDetector(
                          onTap: () {
                            onWalletSelected(wallet.id);
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? wallet.color
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? wallet.color.withValues(alpha: 0.08)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: wallet.color.withValues(
                                    alpha: 0.15,
                                  ),
                                  child: Icon(
                                    wallet.icon,
                                    color: wallet.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        wallet.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? wallet.color
                                              : Colors.black87,
                                        ),
                                      ),
                                      if (showBalance) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.formatVND(
                                            wallet.balance,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: wallet.balance >= 0
                                                ? Colors.green.shade600
                                                : Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: wallet.color,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

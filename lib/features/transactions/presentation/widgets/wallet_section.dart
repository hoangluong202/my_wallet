import 'package:flutter/material.dart';
import '../../../wallets/presentation/model/wallet_view_data.dart';
import 'form_section_label.dart';

class WalletSection extends StatefulWidget {
  final List<WalletViewData> wallets;
  final String? selectedWalletId;
  final ValueChanged<String> onSelected;
  final bool showLabel;

  const WalletSection({
    super.key,
    required this.wallets,
    required this.selectedWalletId,
    required this.onSelected,
    this.showLabel = false,
  });

  @override
  State<WalletSection> createState() => _WalletSectionState();
}

class _WalletSectionState extends State<WalletSection> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final selectedWallet = widget.wallets
        .where((wallet) => wallet.id == widget.selectedWalletId)
        .firstOrNull;

    if (widget.wallets.isEmpty) {
      return Text(
        'No wallets available',
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    return TapRegion(
      onTapOutside: (_) {
        if (_isOpen) setState(() => _isOpen = false);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showLabel) ...[
                const FormSectionLabel(
                  title: 'Wallet',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _WalletSelectorButton(
                  wallet: selectedWallet,
                  isOpen: _isOpen,
                  onTap: () => setState(() => _isOpen = !_isOpen),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: _isOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.wallets
                          .map(
                            (wallet) => _WalletButton(
                              wallet: wallet,
                              selected: wallet.id == widget.selectedWalletId,
                              onTap: () {
                                widget.onSelected(wallet.id);
                                setState(() => _isOpen = false);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _WalletSelectorButton extends StatelessWidget {
  const _WalletSelectorButton({
    required this.wallet,
    required this.isOpen,
    required this.onTap,
  });

  final WalletViewData? wallet;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: wallet?.color.withValues(alpha: 0.08) ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isOpen
                    ? (wallet?.color ?? Theme.of(context).colorScheme.primary)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  wallet?.icon ?? Icons.account_balance_wallet_outlined,
                  size: 19,
                  color: wallet?.color ?? Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    wallet?.name ?? 'Select a wallet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: wallet == null
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: wallet?.color ?? Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  const _WalletButton({
    required this.wallet,
    required this.selected,
    required this.onTap,
  });

  final WalletViewData wallet;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? wallet.color.withValues(alpha: 0.12)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? wallet.color : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(wallet.icon, color: wallet.color, size: 18),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  wallet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? wallet.color : Colors.black87,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle, color: wallet.color, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

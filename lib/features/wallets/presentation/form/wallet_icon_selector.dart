import 'package:flutter/material.dart';
import '../constants/wallet_icons.dart';

class WalletIconSelector extends StatelessWidget {
  final IconData selectedIcon;
  final Color selectedIconColor;
  final Function(IconData, Color) onIconSelected;

  const WalletIconSelector({
    super.key,
    required this.selectedIcon,
    required this.selectedIconColor,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildIconList()],
    );
  }

  Widget _buildIconList() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: WalletIcons.icons.length,
        itemBuilder: (context, index) {
          final iconData = WalletIcons.icons[index];
          final isSelected =
              iconData.icon == selectedIcon &&
              iconData.color == selectedIconColor;

          return _IconOption(
            iconData: WalletIconData(
              icon: iconData.icon,
              color: iconData.color,
            ),
            isSelected: isSelected,
            onTap: () => onIconSelected(iconData.icon, iconData.color),
          );
        },
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  final WalletIconData iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: iconData.color, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: iconData.color.withValues(alpha: 0.2),
          child: Icon(iconData.icon, size: 22, color: iconData.color),
        ),
      ),
    );
  }
}

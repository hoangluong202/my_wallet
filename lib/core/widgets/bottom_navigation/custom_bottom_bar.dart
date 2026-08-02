import 'package:flutter/material.dart';
import 'bottom_bar_item_model.dart';
import 'bottom_nav_item.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<BottomBarItemModel> items;

  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF171B22)
        : const Color(0xFFF8FAFC);
    final backgroundColor = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.025),
      baseColor,
    );
    final borderColor = theme.colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.35 : 0.55,
    );

    return BottomAppBar(
      color: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
      shape: AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          side: BorderSide(color: borderColor),
        ),
        const StadiumBorder(),
      ),
      notchMargin: 7,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          children: [
            Expanded(
              flex: 9,
              child: BottomNavItem(
                item: items[0],
                selected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
            ),
            Expanded(
              flex: 11,
              child: BottomNavItem(
                item: items[1],
                selected: selectedIndex == 1,
                onTap: () => onTabSelected(1),
              ),
            ),
            const SizedBox(width: 56),
            Expanded(
              flex: 10,
              child: BottomNavItem(
                item: items[2],
                selected: selectedIndex == 2,
                onTap: () => onTabSelected(2),
              ),
            ),
            Expanded(
              flex: 10,
              child: BottomNavItem(
                item: items[3],
                selected: selectedIndex == 3,
                onTap: () => onTabSelected(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

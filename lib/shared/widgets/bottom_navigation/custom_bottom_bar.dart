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
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      padding: EdgeInsets.zero,
      elevation: 8,
      child: SizedBox(
        height: 65,
        child: Row(
          children: [
            // Home
            Expanded(
              flex: 1,
              child: BottomNavItem(
                item: items[0],
                selected: selectedIndex == 0,
                onTap: () => onTabSelected(0),
              ),
            ),
            // Wallets - pushed to left with spacer
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: BottomNavItem(
                  item: items[1],
                  selected: selectedIndex == 1,
                  onTap: () => onTabSelected(1),
                ),
              ),
            ),
            // Spacer for FAB
            const SizedBox(width: 60),
            // Transactions - pushed to right with spacer
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: BottomNavItem(
                  item: items[2],
                  selected: selectedIndex == 2,
                  onTap: () => onTabSelected(2),
                ),
              ),
            ),
            // Category
            Expanded(
              flex: 1,
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
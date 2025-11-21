import 'package:flutter/material.dart';
import '../../shared/widgets/bottom_navigation/bottom_bar_item_model.dart';

class NavigationItems {
  static const List<BottomBarItemModel> mainNavItems = [
    BottomBarItemModel(label: 'Home', icon: Icons.home, index: 0),
    BottomBarItemModel(
      label: 'Wallets',
      icon: Icons.account_balance_wallet,
      index: 1,
    ),
    BottomBarItemModel(label: 'Transactions', icon: Icons.swap_horiz, index: 2),
    BottomBarItemModel(label: 'Category', icon: Icons.category, index: 3),
  ];
}

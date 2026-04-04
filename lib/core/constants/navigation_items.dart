import 'package:flutter/material.dart';
import '../widgets/bottom_navigation/bottom_bar_item_model.dart';

class NavigationItems {
  static const List<BottomBarItemModel> mainNavItems = [
    BottomBarItemModel(label: 'Home', icon: Icons.home, index: 0),
    BottomBarItemModel(label: 'Transactions', icon: Icons.swap_horiz, index: 1),
    BottomBarItemModel(label: 'Budget', icon: Icons.pie_chart, index: 2),
    BottomBarItemModel(label: 'User', icon: Icons.person, index: 3),
  ];
}

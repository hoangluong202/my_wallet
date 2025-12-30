import 'package:flutter/material.dart';
import '../constants/wallet_icons.dart';

class WalletIconHelper {
  /// Get icon data by codePoint
  static WalletIconData? getIconDataByCodePoint(int codePoint) {
    return WalletIcons.getIconByCodePoint(codePoint);
  }

  /// Build icon with background from iconCode
  static Widget buildIconWithBackground(
    int codePoint, {
    double size = 26,
    double padding = 10,
    double borderRadius = 12,
  }) {
    final iconData = WalletIcons.getIconByCodePoint(codePoint);
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: iconData.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: Icon(iconData.icon, color: iconData.color, size: size),
    );
  }
}

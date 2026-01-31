import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final EdgeInsets? padding;
  final double? titleFontSize;
  final Color? titleColor;
  final double? iconSize;

  const CardSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.padding,
    this.titleFontSize = 13,
    this.titleColor,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: iconSize,
                color: titleColor ?? Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}

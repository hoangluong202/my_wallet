import 'package:flutter/material.dart';

import '../constants/category_icons.dart';

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.icons,
    required this.selectedIcon,
    required this.onSelected,
  });

  final List<IconData> icons;
  final IconData selectedIcon;
  final ValueChanged<IconData> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            final color = CategoryIcons.getIconByCodePoint(
              icon.codePoint,
            ).color;
            final selected = icon == selectedIcon;
            return InkWell(
              onTap: () => onSelected(icon),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: selected ? 0.16 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../categories/domain/category.dart';
import '../../../categories/presentation/constants/category_icons.dart';
import '../../../categories/presentation/helpers/label.dart';

class TransactionTypeSelector extends StatelessWidget {
  final CategoryType selectedType;
  final ValueChanged<CategoryType> onTypeChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: CategoryTypeIcons.typeIcons.entries.map((entry) {
          final type = entry.key;
          final isSelected = selectedType == type;
          final typeIcon = entry.value;
          final label = LabelHelper.getCategoryLabel(type);
          return Expanded(
            child: _TypeChip(
              typeIcon: typeIcon,
              label: label,
              isSelected: isSelected,
              onTap: () => onTypeChanged(type),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final CategoryIconData typeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.typeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? typeIcon.color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? typeIcon.color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeIcon.icon,
              color: isSelected ? typeIcon.color : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? typeIcon.color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

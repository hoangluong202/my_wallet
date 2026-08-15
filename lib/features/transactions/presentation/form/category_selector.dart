import 'package:flutter/material.dart';

import '../../../categories/presentation/model/category_view_data.dart';
import '../../../categories/presentation/widgets/hierarchical_category_picker.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.showLabel = false,
  });

  final List<CategoryViewData> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return HierarchicalCategoryPicker(
      categories: categories,
      selectedCategoryId: selectedId,
      onSelected: (category) => onSelected(category.id),
      leading: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

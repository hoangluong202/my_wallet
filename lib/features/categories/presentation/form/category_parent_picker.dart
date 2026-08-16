import 'package:flutter/material.dart';

import '../model/category_view_data.dart';
import '../widgets/hierarchical_category_picker.dart';

class CategoryParentPicker extends StatelessWidget {
  const CategoryParentPicker({
    super.key,
    required this.parents,
    required this.selectedId,
    required this.onChanged,
    this.enabled = true,
  });

  final List<CategoryViewData> parents;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final mainCategories = parents
        .where((category) => category.parentCategoryId == null)
        .toList();
    final validSelectedId =
        mainCategories.any((category) => category.id == selectedId)
        ? selectedId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (enabled)
          HierarchicalCategoryPicker(
            categories: mainCategories,
            selectedCategoryId: validSelectedId,
            leading: Text(
              'Hierarchy',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            emptySelectionLabel: 'Main category',
            clearSelectionLabel: 'Main category',
            showChildren: false,
            onCleared: () => onChanged(null),
            onSelected: (category) => onChanged(category.id),
          )
        else
          Row(
            children: [
              Text('Hierarchy', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_tree_outlined,
                        size: 19,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Main category',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 5),
        Text(
          enabled
              ? 'Choose a parent only when this is a subcategory.'
              : 'This category has subcategories, so it must remain a main category.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../categories/presentation/model/category_view_data.dart';
import '../../../categories/presentation/widgets/hierarchical_category_picker.dart';
import '../widgets/form_section_label.dart';

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
          ? const FormSectionLabel(
              title: 'Category',
              icon: Icons.category_outlined,
            )
          : null,
    );
  }
}

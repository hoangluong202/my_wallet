import 'package:flutter/material.dart';
import '../../../categories/presentation/model/category_view_data.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryViewData> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  CategoryViewData? get _selectedCategory {
    return categories.where((c) => c.id == selectedId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return _selectedCategory == null
        ? _buildPlaceholder(context)
        : _buildSelected(context, _selectedCategory!);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: Colors.grey.shade500, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Select a category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildSelected(BuildContext context, CategoryViewData category) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    if (categories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No categories available')));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Select Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildPickerItem(context, category);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerItem(BuildContext context, CategoryViewData category) {
    final isSelected = selectedId == category.id;

    return GestureDetector(
      onTap: () {
        onSelected(category.id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? category.color
                : category.color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? category.color.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              radius: 18,
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 12),

            // Name
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? category.color : Colors.black87,
                ),
              ),
            ),

            // Selected indicator
            if (isSelected)
              Icon(Icons.check_circle, color: category.color, size: 24),
          ],
        ),
      ),
    );
  }
}

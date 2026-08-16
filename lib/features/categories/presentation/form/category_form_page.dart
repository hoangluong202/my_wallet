import 'package:flutter/material.dart';

import '../../../../core/widgets/header/detail_header.dart';
import '../../domain/category.dart';
import '../constants/category_icons.dart';
import '../helpers/label.dart';
import '../model/category_view_data.dart';
import 'category_form_value.dart';
import 'category_icon_picker.dart';
import 'category_name_field.dart';
import 'category_parent_picker.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    super.key,
    required this.title,
    required this.type,
    required this.categoriesStream,
    required this.validateName,
    required this.onSubmit,
    required this.submitLabel,
    this.initialName = '',
    this.initialIcon = Icons.category_rounded,
    this.initialParentId,
    this.categoryId,
  });

  final String title;
  final CategoryType type;
  final Stream<List<CategoryViewData>> categoriesStream;
  final String? Function(String?) validateName;
  final Future<bool> Function(CategoryFormValue value) onSubmit;
  final String submitLabel;
  final String initialName;
  final IconData initialIcon;
  final String? initialParentId;
  final String? categoryId;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late IconData _selectedIcon;
  late String? _parentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedIcon = widget.initialIcon;
    _parentId = widget.initialParentId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = CategoryIcons.getIconsByType(
      widget.type,
    ).map((item) => item.icon).toList();
    final selectedColor = CategoryIcons.getIconByCodePoint(
      _selectedIcon.codePoint,
    ).color;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            DetailHeader(
              title: widget.title,
              onBack: () => Navigator.maybePop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryNameField(
                              controller: _nameController,
                              icon: _selectedIcon,
                              color: selectedColor,
                              typeLabel: LabelHelper.getCategoryLabel(
                                widget.type,
                              ),
                              validator: widget.validateName,
                              autofocus: widget.initialName.isEmpty,
                            ),
                            const SizedBox(height: 20),
                            CategoryIconPicker(
                              icons: icons,
                              selectedIcon: _selectedIcon,
                              onSelected: (icon) =>
                                  setState(() => _selectedIcon = icon),
                            ),
                            const SizedBox(height: 20),
                            _buildParentPicker(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSubmitButton(selectedColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentPicker() {
    return StreamBuilder<List<CategoryViewData>>(
      stream: widget.categoriesStream,
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        final hasChildren =
            widget.categoryId != null &&
            categories.any(
              (item) => item.parentCategoryId == widget.categoryId,
            );
        final parents = categories
            .where(
              (item) =>
                  item.type == widget.type &&
                  item.parentCategoryId == null &&
                  item.id != widget.categoryId,
            )
            .toList();
        return CategoryParentPicker(
          parents: parents,
          selectedId: hasChildren ? null : _parentId,
          enabled: !hasChildren,
          onChanged: (value) => setState(() => _parentId = value),
        );
      },
    );
  }

  Widget _buildSubmitButton(Color color) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: _isSaving ? null : _submit,
        style: FilledButton.styleFrom(backgroundColor: color),
        child: _isSaving
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.submitLabel),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final success = await widget.onSubmit(
      CategoryFormValue(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        parentCategoryId: _parentId,
      ),
    );
    if (mounted && !success) setState(() => _isSaving = false);
  }
}

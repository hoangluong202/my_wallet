import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../constants/category_icons.dart';
import '../model/category_view_data.dart';
import '../../domain/category.dart';
import '../list/categories_viewmodel.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../data/repositories/categories_repository.dart';

class EditCategoryPage extends StatefulWidget {
  final CategoryViewData category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late final CategoriesViewModel _viewModel;
  late List<IconData> _availableIcons;
  late String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    final repository = GetIt.instance<CategoriesRepository>();
    _viewModel = CategoriesViewModel(repository);
    _nameController = TextEditingController(text: widget.category.name);
    _selectedIcon = widget.category.icon;
    _selectedParentId = widget.category.parentCategoryId;
    _availableIcons = CategoryIcons.getIconsByType(
      widget.category.type,
    ).map((iconData) => iconData.icon).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    print('Submitting form...');
    if (!_formKey.currentState!.validate()) return;
    final category = Category(
      id: widget.category.id,
      name: _nameController.text.trim(),
      type: widget.category.type,
      iconCode: _selectedIcon.codePoint,
      parentCategoryId: _selectedParentId,
      createdAt: widget.category.createdAt,
      updatedAt: DateTime.now(),
    );
    print('Updating category: ${category.iconCode}');
    final success = await _viewModel.updateCategoryWithValidation(category);

    if (!mounted) return;

    if (success) {
      SuccessNotification.show(
        context: context,
        message: 'Category updated successfully!',
      );
      Navigator.pop(context, true);
    } else {
      ErrorNotification.show(
        context: context,
        message: _viewModel.errorMessage ?? 'Failed to update category',
        duration: const Duration(seconds: 4),
      );
    }
  }

  Color _getColorForIcon(IconData icon) {
    final iconData = CategoryIcons.getIconByCodePoint(icon.codePoint);
    return iconData.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Icon Selector Card
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.palette_outlined,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Icon & Color',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Selected Icon Preview
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: _getColorForIcon(
                                        _selectedIcon,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      _selectedIcon,
                                      size: 48,
                                      color: _getColorForIcon(_selectedIcon),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Icon Grid
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _availableIcons
                                      .map(
                                        (icon) => GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedIcon = icon,
                                          ),
                                          child: Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: _selectedIcon == icon
                                                  ? _getColorForIcon(
                                                      icon,
                                                    ).withOpacity(0.15)
                                                  : Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _selectedIcon == icon
                                                    ? _getColorForIcon(icon)
                                                    : Colors.grey.shade200,
                                                width: 2,
                                              ),
                                            ),
                                            child: Icon(
                                              icon,
                                              size: 24,
                                              color: _getColorForIcon(icon),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // NEW: Parent Category Selector
                        _buildParentCategorySelector(),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Category Name',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter category name',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  validator: (value) => _viewModel
                                      .validateCategoryName(value ?? ''),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Save Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            'Edit ${widget.category.name}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // NEW: Build parent category selector widget
  Widget _buildParentCategorySelector() {
    return StreamBuilder<List<CategoryViewData>>(
      stream: _viewModel.categoriesStream,
      builder: (context, snapshot) {
        final allCategories = snapshot.data ?? [];

        // Check if current category has any children
        final hasChildren = allCategories.any(
          (c) => c.parentCategoryId == widget.category.id,
        );

        // If has children, don't show parent selector at all
        if (hasChildren) {
          return const SizedBox.shrink();
        }

        final availableParents = allCategories
            .where(
              (c) =>
                  c.type == widget.category.type &&
                  c.parentCategoryId == null &&
                  c.id != widget.category.id,
            ) // Exclude self
            .toList();

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Parent Category (Optional)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (availableParents.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'No parent categories available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  _buildBeautifulParentSelector(availableParents),
              ],
            ),
          ),
        );
      },
    );
  }

  // Beautiful parent selector with custom design
  Widget _buildBeautifulParentSelector(
    List<CategoryViewData> availableParents,
  ) {
    // Get selected parent info if any
    final selectedParent = _selectedParentId != null
        ? availableParents.firstWhere(
            (p) => p.id == _selectedParentId,
            orElse: () => availableParents.first,
          )
        : null;

    return PopupMenuButton<String?>(
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      itemBuilder: (BuildContext context) {
        return [
          // "None" option
          PopupMenuItem<String?>(
            value: null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.clear_all,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'None',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Root Category',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Divider
          const PopupMenuDivider(height: 8),
          // Parent categories
          ...availableParents.map((parent) {
            return PopupMenuItem<String?>(
              value: parent.id,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: parent.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(parent.icon, size: 16, color: parent.color),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    parent.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ];
      },
      onSelected: (String? value) {
        setState(() {
          _selectedParentId = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (selectedParent != null)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selectedParent.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      selectedParent.icon,
                      size: 14,
                      color: selectedParent.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedParent.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 8),
                  Text(
                    'Select a parent category',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                ],
              ),
            const Spacer(),
            Icon(Icons.unfold_more, size: 18, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

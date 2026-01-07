import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../constants/category_icons.dart';
import '../../domain/category.dart';
import '../../presentation/helpers/label.dart';
import '../list/categories_viewmodel.dart';
import '../../data/repositories/categories_repository.dart';
import '../../../../core/widgets/notification_widget.dart';

class AddCategoryPage extends StatefulWidget {
  final CategoryType preselectedType;

  const AddCategoryPage({super.key, required this.preselectedType});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late CategoryType _selectedType;
  late final CategoriesViewModel _viewModel;

  final List<IconData> _availableIcons = CategoryIcons.icons
      .map((iconData) => iconData.icon)
      .toList();

  @override
  void initState() {
    super.initState();
    final repository = GetIt.instance<CategoriesRepository>();
    _viewModel = CategoriesViewModel(repository);
    _nameController = TextEditingController();
    _selectedIcon = Icons.category;
    _selectedType = widget.preselectedType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    final category = Category(
      id: Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      iconCode: _selectedIcon.codePoint,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final success = await _viewModel.addCategory(category);

    if (!mounted) return;

    if (success) {
      SuccessNotification.show(
        context: context,
        message: 'Category created successfully!',
      );
      Navigator.pop(context, true);
    } else {
      ErrorNotification.show(
        context: context,
        message: _viewModel.errorMessage ?? 'Failed to create category',
        duration: const Duration(seconds: 4),
      );
    }
  }

  Color _getColorForIcon(IconData icon) {
    final index = _availableIcons.indexOf(icon) % 5;
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.green,
    ];
    return colors[index];
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
                                                    ).withValues(alpha: 0.15)
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
                        // Category Name Card
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
                                    hintText: 'e.g., Food, Transport',
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
                                  validator: (value) => _viewModel.validateCategoryName(
                                    value ?? ''
                                  ),
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
                    'Save Category',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              Text(
                'Add ${LabelHelper.getCategoryLabel(_selectedType)} Category',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

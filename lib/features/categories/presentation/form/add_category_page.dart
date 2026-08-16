import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/notification_widget.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/category.dart';
import '../list/categories_viewmodel.dart';
import 'category_form_page.dart';
import 'category_form_value.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key, required this.preselectedType});

  final CategoryType preselectedType;

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  late final CategoriesViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CategoriesViewModel(GetIt.I<CategoriesRepository>());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryFormPage(
      title: 'Add category',
      type: widget.preselectedType,
      categoriesStream: _viewModel.categoriesStream,
      validateName: _viewModel.validateCategoryName,
      submitLabel: 'Create category',
      onSubmit: _create,
    );
  }

  Future<bool> _create(CategoryFormValue value) async {
    final now = DateTime.now();
    final success = await _viewModel.addCategoryWithValidation(
      Category(
        id: const Uuid().v4(),
        name: value.name,
        type: widget.preselectedType,
        iconCode: value.icon.codePoint,
        parentCategoryId: value.parentCategoryId,
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (!mounted) return success;
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
      );
    }
    return success;
  }
}

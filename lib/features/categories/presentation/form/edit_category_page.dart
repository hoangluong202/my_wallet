import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/widgets/notification_widget.dart';
import '../../data/repositories/categories_repository.dart';
import '../../domain/category.dart';
import '../list/categories_viewmodel.dart';
import '../model/category_view_data.dart';
import 'category_form_page.dart';
import 'category_form_value.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key, required this.category});

  final CategoryViewData category;

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
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
    final category = widget.category;
    return CategoryFormPage(
      title: 'Edit category',
      type: category.type,
      categoryId: category.id,
      initialName: category.name,
      initialIcon: category.icon,
      initialParentId: category.parentCategoryId,
      categoriesStream: _viewModel.categoriesStream,
      validateName: _viewModel.validateCategoryName,
      submitLabel: 'Save changes',
      onSubmit: _update,
    );
  }

  Future<bool> _update(CategoryFormValue value) async {
    final current = widget.category;
    final success = await _viewModel.updateCategoryWithValidation(
      Category(
        id: current.id,
        name: value.name,
        type: current.type,
        iconCode: value.icon.codePoint,
        parentCategoryId: value.parentCategoryId,
        createdAt: current.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
    if (!mounted) return success;
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
      );
    }
    return success;
  }
}

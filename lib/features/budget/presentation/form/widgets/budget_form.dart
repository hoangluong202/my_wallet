import 'package:flutter/material.dart';

import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../../categories/domain/category.dart';
import '../../../../categories/presentation/model/category_view_data.dart';
import '../../viewmodel/budget_viewmodel.dart';

part 'budget_form_item.dart';
part 'budget_form_header.dart';
part 'budget_period_fields.dart';
part 'budget_item_card.dart';
part 'budget_submit_button.dart';
part 'budget_shared_widgets.dart';

class BudgetForm extends StatelessWidget {
  const BudgetForm({
    required this.formKey,
    required this.viewModel,
    required this.items,
    required this.startDate,
    required this.endDate,
    required this.isEditMode,
    required this.onItemChanged,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPickMonth,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final BudgetViewModel viewModel;
  final List<BudgetFormItem> items;
  final DateTime startDate;
  final DateTime endDate;
  final bool isEditMode;
  final VoidCallback onItemChanged;
  final VoidCallback onAddItem;
  final ValueChanged<int> onRemoveItem;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPickMonth;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            if (isEditMode)
              _DateRangeCard(
                startDate: startDate,
                endDate: endDate,
                onStartDateTap: onStartDateTap,
                onEndDateTap: onEndDateTap,
              )
            else
              _MonthCard(
                month: startDate,
                onPrevious: onPreviousMonth,
                onNext: onNextMonth,
                onTap: onPickMonth,
              ),
            const SizedBox(height: 12),
            StreamBuilder<List<CategoryViewData>>(
              stream: viewModel.watchAllCategories(),
              builder: (context, snapshot) {
                final categories = snapshot.data ?? [];
                final expenseCategories = categories
                    .where((category) => category.type == CategoryType.expense)
                    .toList();
                return Column(
                  children: [
                    for (var index = 0; index < items.length; index++) ...[
                      _BudgetItemCard(
                        key: ObjectKey(items[index]),
                        item: items[index],
                        categories: expenseCategories,
                        canRemove: !isEditMode && items.length > 1,
                        onChanged: onItemChanged,
                        onToggleCategoryPicker: () {
                          final shouldOpen = !items[index].isCategoryPickerOpen;
                          for (final item in items) {
                            item.isCategoryPickerOpen = false;
                          }
                          items[index].isCategoryPickerOpen = shouldOpen;
                          onItemChanged();
                        },
                        onRemove: () => onRemoveItem(index),
                        validateAmount: viewModel.validateAmount,
                      ),
                      if (index < items.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            _BudgetSummary(
              items: items,
              showAddButton: !isEditMode,
              onAdd: onAddItem,
            ),
            const SizedBox(height: 12),
            _SubmitButton(
              viewModel: viewModel,
              isEditMode: isEditMode,
              itemCount: items.length,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

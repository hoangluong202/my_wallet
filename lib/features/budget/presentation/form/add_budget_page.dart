import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../../core/widgets/month_picker_bottom_sheet.dart';
import '../viewmodel/budget_viewmodel.dart';
import 'budget_payload.dart';
import 'widgets/budget_form.dart';

class AddBudgetPage extends StatefulWidget {
  const AddBudgetPage({
    super.key,
    this.budgetId,
    this.initialCategoryId,
    this.initialEstimatedAmount,
    this.initialStartDate,
    this.initialEndDate,
  });

  final String? budgetId;
  final String? initialCategoryId;
  final int? initialEstimatedAmount;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  bool get isEditMode => budgetId != null;

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late final BudgetViewModel _viewModel;
  late final List<BudgetFormItem> _items;
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<BudgetViewModel>();
    _items = [
      BudgetFormItem(
        categoryId: widget.initialCategoryId,
        amount: widget.initialEstimatedAmount == null
            ? ''
            : CurrencyFormatter.formatVND(widget.initialEstimatedAmount!),
      ),
    ];
    if (widget.isEditMode) {
      _startDate = DateUtils.dateOnly(
        widget.initialStartDate ?? DateTime.now(),
      );
      _endDate = DateUtils.dateOnly(
        widget.initialEndDate ?? DateTime.now().add(const Duration(days: 30)),
      );
    } else {
      _setMonth(DateTime.now());
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _setMonth(DateTime month) {
    _startDate = DateTime(month.year, month.month);
    _endDate = DateTime(month.year, month.month + 1, 0);
  }

  void _changeMonth(int offset) => setState(
    () => _setMonth(DateTime(_startDate.year, _startDate.month + offset)),
  );

  Future<void> _pickMonth() async {
    final picked = await showMonthPickerBottomSheet(
      context: context,
      initialMonth: _startDate,
    );
    if (picked != null) setState(() => _setMonth(picked));
  }

  void _addItem() => setState(() => _items.add(BudgetFormItem()));

  void _removeItem(int index) {
    final removed = _items.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_endDate.isAfter(_startDate)) {
      context.showErrorMessage('End date must be after start date');
      return;
    }

    final categoryIds = _items.map((item) => item.categoryId!).toList();
    if (categoryIds.toSet().length != categoryIds.length) {
      context.showErrorMessage('Each category can only have one budget');
      return;
    }

    final now = DateTime.now();
    final payloads = _items
        .map(
          (item) => BudgetPayload(
            id: widget.isEditMode ? widget.budgetId! : const Uuid().v4(),
            categoryId: item.categoryId!,
            estimatedAmount: CurrencyFormatter.parseVND(
              item.amountController.text,
            ),
            startDate: _startDate,
            endDate: _endDate,
            createdAt: widget.isEditMode ? widget.initialStartDate ?? now : now,
            updatedAt: now,
          ),
        )
        .toList();
    final success = widget.isEditMode
        ? await _viewModel.updateBudget(payloads.single)
        : await _viewModel.addBudgets(payloads);

    if (!mounted) return;
    if (success) {
      SuccessNotification.show(
        context: context,
        message: widget.isEditMode
            ? 'Budget updated successfully!'
            : '${payloads.length} budgets created successfully!',
      );
      Navigator.pop(context, true);
      return;
    }
    ErrorNotification.show(
      context: context,
      message: _viewModel.errorMessage ?? 'Failed to save budget',
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isAfter(_startDate) ? _endDate : _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    resizeToAvoidBottomInset: true,
    body: SafeArea(
      child: Column(
        children: [
          BudgetFormHeader(
            isEditMode: widget.isEditMode,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: BudgetForm(
              formKey: _formKey,
              viewModel: _viewModel,
              items: _items,
              startDate: _startDate,
              endDate: _endDate,
              isEditMode: widget.isEditMode,
              onItemChanged: () => setState(() {}),
              onAddItem: _addItem,
              onRemoveItem: _removeItem,
              onPreviousMonth: () => _changeMonth(-1),
              onNextMonth: () => _changeMonth(1),
              onPickMonth: _pickMonth,
              onStartDateTap: _pickStartDate,
              onEndDateTap: _pickEndDate,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    ),
  );
}

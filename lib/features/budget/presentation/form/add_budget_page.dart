import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../../core/widgets/notification_widget.dart';
import '../../../categories/presentation/model/category_view_data.dart';
import '../viewmodel/budget_viewmodel.dart';
import 'budget_payload.dart';

class AddBudgetPage extends StatefulWidget {
  /// When provided the form operates in edit mode.
  final String? budgetId;
  final String? initialCategoryId;
  final int? initialEstimatedAmount;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const AddBudgetPage({
    super.key,
    this.budgetId,
    this.initialCategoryId,
    this.initialEstimatedAmount,
    this.initialStartDate,
    this.initialEndDate,
  });

  bool get isEditMode => budgetId != null;

  @override
  State<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late final BudgetViewModel _viewModel;
  late final TextEditingController _amountController;

  String? _selectedCategoryId;
  DateTime _startDate = DateUtils.dateOnly(DateTime.now());
  DateTime _endDate = DateUtils.dateOnly(
    DateTime.now().add(const Duration(days: 30)),
  );

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.instance<BudgetViewModel>();
    _amountController = TextEditingController(
      text: widget.initialEstimatedAmount != null
          ? CurrencyFormatter.formatVND(widget.initialEstimatedAmount!)
          : '',
    );
    _selectedCategoryId = widget.initialCategoryId;
    if (widget.initialStartDate != null) {
      _startDate = DateUtils.dateOnly(widget.initialStartDate!);
    }
    if (widget.initialEndDate != null) {
      _endDate = DateUtils.dateOnly(widget.initialEndDate!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      context.showErrorMessage('Please select a category');
      return;
    }
    if (!_endDate.isAfter(_startDate)) {
      context.showErrorMessage('End date must be after start date');
      return;
    }

    final amount = CurrencyFormatter.parseVND(_amountController.text);
    final now = DateTime.now();

    final payload = BudgetPayload(
      id: widget.budgetId ?? const Uuid().v4(),
      categoryId: _selectedCategoryId!,
      estimatedAmount: amount,
      startDate: _startDate,
      endDate: _endDate,
      createdAt: widget.isEditMode ? widget.initialStartDate ?? now : now,
      updatedAt: now,
    );

    final success = widget.isEditMode
        ? await _viewModel.updateBudget(payload)
        : await _viewModel.addBudget(payload);

    if (!mounted) return;

    if (success) {
      SuccessNotification.show(
        context: context,
        message: widget.isEditMode
            ? 'Budget updated successfully!'
            : 'Budget created successfully!',
      );
      Navigator.pop(context, true);
    } else {
      ErrorNotification.show(
        context: context,
        message: _viewModel.errorMessage ?? 'Failed to save budget',
        duration: const Duration(seconds: 4),
      );
    }
  }

  // ─── Date pickers ─────────────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAmountCard(),
                      const SizedBox(height: 12),
                      _buildCategoryCard(),
                      const SizedBox(height: 12),
                      _buildDateRangeCard(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
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

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.isEditMode ? 'Edit Budget' : 'New Budget',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Amount card ──────────────────────────────────────────────────────────

  Widget _buildAmountCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel(Icons.attach_money, 'Estimated Amount'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandSeparatorInputFormatter()],
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'đ',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            validator: _viewModel.validateAmount,
          ),
        ],
      ),
    );
  }

  // ─── Category card ────────────────────────────────────────────────────────

  Widget _buildCategoryCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel(Icons.category_outlined, 'Category'),
          const SizedBox(height: 12),
          StreamBuilder<List<CategoryViewData>>(
            stream: _viewModel.watchAllCategories(),
            builder: (context, snapshot) {
              final categories = snapshot.data ?? [];
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedCategoryId = cat.id;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected
                                ? cat.color
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? cat.color
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── Date range card ──────────────────────────────────────────────────────

  Widget _buildDateRangeCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardLabel(Icons.date_range_outlined, 'Date Range'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateField(
                  label: 'Start',
                  date: _startDate,
                  onTap: _pickStartDate,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ),
              Expanded(
                child: _DateField(
                  label: 'End',
                  date: _endDate,
                  onTap: _pickEndDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Submit button ────────────────────────────────────────────────────────

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: ValueNotifier(_viewModel.isLoading),
      builder: (_, __, ___) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _viewModel.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _viewModel.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.isEditMode ? 'Save Changes' : 'Create Budget',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────

  Widget _cardLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}

// ─── Reusable card wrapper ────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

// ─── Date field ───────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatDate(date),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

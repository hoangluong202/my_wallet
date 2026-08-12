part of 'budget_form.dart';

class _BudgetItemCard extends StatelessWidget {
  const _BudgetItemCard({
    super.key,
    required this.item,
    required this.categories,
    required this.canRemove,
    required this.onChanged,
    required this.onToggleCategoryPicker,
    required this.onRemove,
    required this.validateAmount,
  });

  final BudgetFormItem item;
  final List<CategoryViewData> categories;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onToggleCategoryPicker;
  final VoidCallback onRemove;
  final FormFieldValidator<String> validateAmount;

  @override
  Widget build(BuildContext context) => _SwipeToDelete(
    enabled: canRemove,
    onDelete: onRemove,
    child: _FormCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _CategoryField(
                  category: _selectedCategory,
                  isOpen: item.isCategoryPickerOpen,
                  onTap: onToggleCategoryPicker,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 48,
                  child: TextFormField(
                    controller: item.amountController,
                    keyboardType: TextInputType.number,
                    textAlignVertical: TextAlignVertical.center,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    inputFormatters: [ThousandSeparatorInputFormatter()],
                    decoration: _inputDecoration(
                      'Amount',
                    ).copyWith(suffixText: 'đ'),
                    validator: validateAmount,
                  ),
                ),
              ),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: item.isCategoryPickerOpen
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _ExpenseCategoryPicker(
                      categories: categories,
                      selectedCategoryId: item.categoryId,
                      onSelected: (category) {
                        item.categoryId = category.id;
                        item.isCategoryPickerOpen = false;
                        onChanged();
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );

  CategoryViewData? get _selectedCategory {
    for (final category in categories) {
      if (category.id == item.categoryId) return category;
    }
    return null;
  }
}

class _SwipeToDelete extends StatefulWidget {
  const _SwipeToDelete({
    required this.enabled,
    required this.onDelete,
    required this.child,
  });

  final bool enabled;
  final VoidCallback onDelete;
  final Widget child;

  @override
  State<_SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<_SwipeToDelete> {
  static const _actionWidth = 52.0;
  double _offset = 0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    setState(() {
      _offset = (_offset + details.delta.dx).clamp(-_actionWidth, 0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    final velocity = details.primaryVelocity ?? 0;
    final shouldOpen = _offset < -_actionWidth / 2 || velocity < -300;
    setState(() => _offset = shouldOpen ? -_actionWidth : 0);
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        if (widget.enabled)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: _actionWidth,
            child: Material(
              color: Colors.red.shade600,
              child: InkWell(
                onTap: widget.onDelete,
                child: const Center(
                  child: Icon(Icons.delete_outline, color: Colors.white),
                ),
              ),
            ),
          ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            transform: Matrix4.translationValues(_offset, 0, 0),
            child: widget.child,
          ),
        ),
      ],
    ),
  );
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.category,
    required this.isOpen,
    required this.onTap,
  });

  final CategoryViewData? category;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: ValueKey(category?.id),
    height: 48,
    child: TextFormField(
      initialValue: category?.name ?? '',
      readOnly: true,
      canRequestFocus: false,
      onTap: onTap,
      decoration: _inputDecoration('Category').copyWith(
        prefixIcon: category == null
            ? null
            : Icon(category!.icon, color: category!.color, size: 18),
        prefixIconConstraints: const BoxConstraints(minWidth: 32),
        suffixIcon: Icon(
          isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 16,
          color: Colors.grey.shade500,
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 24),
        hintText: 'Choose',
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Select category' : null,
    ),
  );
}

class _ExpenseCategoryPicker extends StatelessWidget {
  const _ExpenseCategoryPicker({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<CategoryViewData> categories;
  final String? selectedCategoryId;
  final ValueChanged<CategoryViewData> onSelected;

  @override
  Widget build(BuildContext context) {
    final parents = categories
        .where((category) => category.parentCategoryId == null)
        .toList();
    final knownParentIds = parents.map((category) => category.id).toSet();
    final orphans = categories
        .where(
          (category) =>
              category.parentCategoryId != null &&
              !knownParentIds.contains(category.parentCategoryId),
        )
        .toList();

    return Container(
      key: const ValueKey('expense-category-picker'),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: categories.isEmpty
          ? Text(
              'No expense categories available',
              style: TextStyle(color: Colors.grey.shade600),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPENSE CATEGORIES',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                for (final parent in parents) ...[
                  _CategoryOption(
                    category: parent,
                    selected: selectedCategoryId == parent.id,
                    onTap: () => onSelected(parent),
                  ),
                  for (final child in categories.where(
                    (category) => category.parentCategoryId == parent.id,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: _CategoryOption(
                        category: child,
                        selected: selectedCategoryId == child.id,
                        onTap: () => onSelected(child),
                        isChild: true,
                      ),
                    ),
                ],
                for (final category in orphans)
                  _CategoryOption(
                    category: category,
                    selected: selectedCategoryId == category.id,
                    onTap: () => onSelected(category),
                  ),
              ],
            ),
    );
  }
}

class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.selected,
    required this.onTap,
    this.isChild = false,
  });

  final CategoryViewData category;
  final bool selected;
  final VoidCallback onTap;
  final bool isChild;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? category.color.withValues(alpha: 0.12)
        : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Row(
          children: [
            if (isChild) ...[
              Icon(
                Icons.subdirectory_arrow_right,
                size: 15,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 5),
            ],
            Icon(category.icon, size: 18, color: category.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: isChild ? 13 : 14,
                  fontWeight: isChild ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, size: 18, color: category.color),
          ],
        ),
      ),
    ),
  );
}

InputDecoration _inputDecoration(String label) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    constraints: const BoxConstraints.tightFor(height: 48),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: border,
    enabledBorder: border,
  );
}

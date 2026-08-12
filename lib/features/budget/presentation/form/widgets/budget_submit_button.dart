part of 'budget_form.dart';

class _BudgetSummary extends StatelessWidget {
  const _BudgetSummary({
    required this.items,
    required this.showAddButton,
    required this.onAdd,
  });

  final List<BudgetFormItem> items;
  final bool showAddButton;
  final VoidCallback onAdd;

  int get _total => items.fold(
    0,
    (total, item) =>
        total +
        (int.tryParse(item.amountController.text.replaceAll('.', '')) ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge(
        items.map((item) => item.amountController).toList(),
      ),
      builder: (context, child) => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const Spacer(),
                  Text(
                    CurrencyFormatter.formatVNDWithSymbol(_total),
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showAddButton) ...[
            const SizedBox(width: 6),
            IconButton.filledTonal(
              tooltip: 'Add budget',
              onPressed: onAdd,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.viewModel,
    required this.isEditMode,
    required this.itemCount,
    required this.onPressed,
  });

  final BudgetViewModel viewModel;
  final bool isEditMode;
  final int itemCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) => SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: viewModel.isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: viewModel.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: colors.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  isEditMode ? 'Save Changes' : 'Create $itemCount Budgets',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

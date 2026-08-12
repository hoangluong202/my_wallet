part of 'budget_form.dart';

class BudgetFormHeader extends StatelessWidget {
  const BudgetFormHeader({
    required this.isEditMode,
    required this.onBack,
    super.key,
  });

  final bool isEditMode;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surface,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBack),
        Expanded(
          child: Text(
            isEditMode ? 'Edit Budget' : 'Create Monthly Budgets',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

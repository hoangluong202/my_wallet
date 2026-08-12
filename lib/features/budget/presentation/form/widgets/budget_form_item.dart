part of 'budget_form.dart';

class BudgetFormItem {
  BudgetFormItem({this.categoryId, String amount = ''})
    : amountController = TextEditingController(text: amount);

  String? categoryId;
  bool isCategoryPickerOpen = false;
  final TextEditingController amountController;

  void dispose() => amountController.dispose();
}

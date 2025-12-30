import '../../domain/category.dart';

class LabelHelper {
  static String getCategoryLabel(CategoryType type) {
    final labels = {
      CategoryType.income: 'Income',
      CategoryType.expense: 'Expense',
      CategoryType.debt: 'Debt',
      CategoryType.loan: 'Loan',
    };
    return labels[type] ?? 'Unknown';
  }
}

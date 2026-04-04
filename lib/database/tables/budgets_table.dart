import 'package:drift/drift.dart';
import 'categories_table.dart';

@DataClassName('BudgetData')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get estimatedAmount => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK(estimated_amount > 0)',
    'CHECK(end_date > start_date)',
    'FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE',
  ];
}

import 'package:drift/drift.dart';

@DataClassName('CategoryData')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  IntColumn get iconCode => integer()();
  TextColumn get type => text()(); // expense, income, debt, loan
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK(length(name) >= 2)',
    "CHECK(type IN ('expense', 'income', 'debt', 'loan'))",
  ];
}

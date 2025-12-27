import 'package:drift/drift.dart';

@DataClassName('WalletData')
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  IntColumn get iconCode => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK(length(name) >= 2)'];
}

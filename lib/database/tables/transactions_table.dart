import 'package:drift/drift.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get walletId => text()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (category_id) REFERENCES categories(id)',
    'FOREIGN KEY (wallet_id) REFERENCES wallets(id)',
    'CHECK(amount > 0)',
  ];
}

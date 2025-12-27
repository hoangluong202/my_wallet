import 'package:drift/drift.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text()();
  TextColumn get walletId => text()();
  IntColumn get amount => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
 
  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (category_id) REFERENCES categories(id)',
    'FOREIGN KEY (wallet_id) REFERENCES wallets(id)',
    'CHECK(amount > 0)',
  ];
}

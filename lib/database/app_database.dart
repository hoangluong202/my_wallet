import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/wallets_table.dart';
import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';
import 'daos/wallet_dao.dart';
import 'daos/user_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';

export 'daos/user_dao.dart';
export 'daos/wallet_dao.dart';
export 'daos/category_dao.dart';
export 'daos/transaction_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Wallets, Users, Categories, Transactions],
  daos: [WalletDao, UserDao, CategoryDao, TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Drop all tables and recreate from scratch
        await m.drop(transactions);
        await m.drop(categories);
        await m.drop(wallets);
        await m.drop(users);

        // Recreate all tables
        await m.createAll();
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Clear all data
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(wallets).go();
      await delete(users).go();
      await delete(categories).go();
    });
  }

  // Delete database file
  Future<void> deleteDatabase() async {
    final file = File(await _getDatabasePath());
    if (await file.exists()) {
      await file.delete();
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'my_wallet.db'));
    return NativeDatabase.createInBackground(file);
  });
}

Future<String> _getDatabasePath() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return p.join(dbFolder.path, 'my_wallet.db');
}

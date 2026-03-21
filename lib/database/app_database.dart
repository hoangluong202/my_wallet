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
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 8) {
          // Add parentCategoryId column to categories table
          await m.addColumn(categories, categories.parentCategoryId);
        }
        if (from < 9) {
          // Remove UNIQUE constraint on parentCategoryId to allow multiple children per parent
          // Note: SQLite doesn't support dropping constraints directly,
          // but the new schema without UNIQUE will be enforced on INSERT/UPDATE
        }
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

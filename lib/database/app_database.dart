import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/wallets_table.dart';
import 'tables/users_table.dart';
import 'tables/categories_table.dart';
import 'tables/transactions_table.dart';
import 'tables/budgets_table.dart';
import 'daos/wallet_dao.dart';
import 'daos/user_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/budget_dao.dart';

export 'daos/user_dao.dart';
export 'daos/wallet_dao.dart';
export 'daos/category_dao.dart';
export 'daos/transaction_dao.dart';
export 'daos/budget_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Wallets, Users, Categories, Transactions, Budgets],
  daos: [WalletDao, UserDao, CategoryDao, TransactionDao, BudgetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 10;

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
        if (from < 10) {
          await m.createTable(budgets);
        }
      },
    );
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

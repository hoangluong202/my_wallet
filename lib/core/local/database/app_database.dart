import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/wallets_table.dart';
import 'daos/wallet_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Wallets], daos: [WalletDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations here
        // Example for version 2:
        // if (from < 2) {
        //   await m.addColumn(wallets, wallets.description);
        // }
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
      await delete(wallets).go();
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

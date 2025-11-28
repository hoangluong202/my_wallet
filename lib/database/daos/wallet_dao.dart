import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/wallets_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  // Get all wallets (excluding deleted ones)
  Future<List<WalletData>> getAllWallets() async {
    return (select(wallets)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Get all wallets including deleted
  Future<List<WalletData>> getAllWalletsIncludingDeleted() async {
    return (select(wallets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  // Get wallet by ID
  Future<WalletData?> getWalletById(String id) async {
    return (select(wallets)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // Insert wallet
  Future<int> insertWallet(WalletsCompanion wallet) async {
    return into(wallets).insert(wallet);
  }

  // Update wallet
  Future<bool> updateWallet(WalletsCompanion wallet) async {
    return update(wallets).replace(wallet);
  }

  // Delete wallet (hard delete)
  Future<int> deleteWallet(String id) async {
    return (delete(wallets)..where((t) => t.id.equals(id))).go();
  }

  // Soft delete wallet (mark as deleted but keep in DB)
  Future<int> softDeleteWallet(String id) async {
    return (update(wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        isDeleted: const Value(true),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Restore deleted wallet
  Future<int> restoreDeletedWallet(String id) async {
    return (update(wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        isDeleted: const Value(false),
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Get total balance
  Future<double> getTotalBalance() async {
    final query = selectOnly(wallets)
      ..addColumns([wallets.balance.sum()])
      ..where(wallets.isDeleted.equals(false));
    final result = await query.getSingleOrNull();
    return result?.read(wallets.balance.sum()) ?? 0.0;
  }

  // Get wallets count
  Future<int> getWalletsCount() async {
    final query = selectOnly(wallets)
      ..addColumns([wallets.id.count()])
      ..where(wallets.isDeleted.equals(false));
    final result = await query.getSingleOrNull();
    return result?.read(wallets.id.count()) ?? 0;
  }

  // Search wallets
  Future<List<WalletData>> searchWallets(String query) async {
    return (select(wallets)
          ..where(
            (t) =>
                (t.name.like('%$query%') |
                    t.name.like('%${query.toUpperCase()}%')) &
                t.isDeleted.equals(false),
          )
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Watch all wallets (excluding deleted)
  Stream<List<WalletData>> watchAllWallets() {
    return (select(wallets)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  // Watch wallet by ID
  Stream<WalletData?> watchWalletById(String id) {
    return (select(wallets)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  // Update wallet balance
  Future<void> updateBalance(String id, double newBalance) async {
    await (update(wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Batch insert wallets
  Future<void> insertWallets(List<WalletsCompanion> walletList) async {
    await batch((batch) {
      batch.insertAll(wallets, walletList);
    });
  }

  // Get dirty wallets (not synced)
  Future<List<WalletData>> getDirtyWallets() async {
    return (select(wallets)
          ..where((t) => t.isSynced.equals(false) & t.isDeleted.equals(false)))
        .get();
  }

  // Get deleted wallets (for sync)
  Future<List<WalletData>> getDeletedWallets() async {
    return (select(wallets)..where((t) => t.isDeleted.equals(true))).get();
  }

  // Mark wallet as synced
  Future<int> markAsSynced(String id) async {
    return (update(wallets)..where((t) => t.id.equals(id))).write(
      const WalletsCompanion(isSynced: Value(true)),
    );
  }

  // Mark wallet as not synced
  Future<int> markAsNotSynced(String id) async {
    return (update(wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        isSynced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Clear all wallets
  Future<int> deleteAllWallets() async {
    return delete(wallets).go();
  }
}

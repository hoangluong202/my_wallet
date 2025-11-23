import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/wallets_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  // Get all wallets
  Future<List<WalletData>> getAllWallets() async {
    return (select(wallets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  // Get wallet by ID
  Future<WalletData?> getWalletById(String id) async {
    return (select(wallets)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Insert wallet
  Future<int> insertWallet(WalletsCompanion wallet) async {
    return into(wallets).insert(wallet);
  }

  // Update wallet
  Future<bool> updateWallet(WalletsCompanion wallet) async {
    return update(wallets).replace(wallet);
  }

  // Delete wallet
  Future<int> deleteWallet(String id) async {
    return (delete(wallets)..where((t) => t.id.equals(id))).go();
  }

  // Get total balance
  Future<double> getTotalBalance() async {
    final query = selectOnly(wallets)..addColumns([wallets.balance.sum()]);
    final result = await query.getSingleOrNull();
    return result?.read(wallets.balance.sum()) ?? 0.0;
  }

  // Get wallets count
  Future<int> getWalletsCount() async {
    final query = selectOnly(wallets)..addColumns([wallets.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(wallets.id.count()) ?? 0;
  }

  // Search wallets
  Future<List<WalletData>> searchWallets(String query) async {
    return (select(wallets)
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // Watch all wallets (Stream)
  Stream<List<WalletData>> watchAllWallets() {
    return (select(wallets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  // Watch wallet by ID (Stream)
  Stream<WalletData?> watchWalletById(String id) {
    return (select(wallets)..where((t) => t.id.equals(id))).watchSingleOrNull();
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
}

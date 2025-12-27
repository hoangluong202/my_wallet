import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/wallets_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  Future<int> getTotalBalance() async {
    final query = selectOnly(wallets)..addColumns([wallets.balance.sum()]);
    final result = await query.getSingleOrNull();
    return result?.read(wallets.balance.sum()) ?? 0;
  }

  Future<int> getWalletsCount() async {
    final query = selectOnly(wallets)..addColumns([wallets.id.count()]);
    final result = await query.getSingleOrNull();
    return result?.read(wallets.id.count()) ?? 0;
  }

  Future<List<WalletData>> getAllWallets() async {
    return (select(wallets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  Stream<List<WalletData>> watchAllWallets() {
    return (select(wallets)..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<WalletData?> getWalletById(String id) async {
    return (select(wallets)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<WalletData?> watchWalletById(String id) {
    return (select(wallets)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<int> insertWallet(WalletsCompanion wallet) async {
    return into(wallets).insert(wallet);
  }

  Future<void> insertWallets(List<WalletsCompanion> walletList) async {
    await batch((batch) {
      batch.insertAll(wallets, walletList);
    });
  }

  Future<bool> updateWallet(WalletsCompanion wallet) async {
    return update(wallets).replace(wallet);
  }

  Future<void> updateBalance(String id, int newBalance) async {
    await (update(wallets)..where((t) => t.id.equals(id))).write(
      WalletsCompanion(
        balance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteWallet(String id) async {
    return (delete(wallets)..where((t) => t.id.equals(id))).go();
  }

  Future<int> deleteAllWallets() async {
    return delete(wallets).go();
  }
}

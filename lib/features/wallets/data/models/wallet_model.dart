import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/wallet.dart';

class WalletModel {
  static Wallet toEntity(WalletData data) {
    return Wallet(
      id: data.id,
      name: data.name,
      balance: data.balance,
      iconCode: data.iconCode,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static WalletsCompanion toCompanion(Wallet entity) {
    return WalletsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      balance: Value(entity.balance),
      iconCode: Value(entity.iconCode),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  static List<Wallet> toEntityList(List<WalletData> dataList) {
    return dataList.map((data) => toEntity(data)).toList();
  }

  static List<WalletsCompanion> toCompanionList(List<Wallet> entityList) {
    return entityList.map((entity) => toCompanion(entity)).toList();
  }

  static WalletsCompanion createNew({
    required String id,
    required String name,
    required int balance,
    required int iconCode,
  }) {
    final now = DateTime.now();
    return WalletsCompanion.insert(
      id: id,
      name: name,
      balance: Value(balance),
      iconCode: iconCode,
      createdAt: now,
      updatedAt: now,
    );
  }

  static WalletsCompanion updateCompanion({
    String? name,
    int? balance,
    int? iconCode,
  }) {
    return WalletsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      balance: balance != null ? Value(balance) : const Value.absent(),
      iconCode: iconCode != null ? Value(iconCode) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
  }
}

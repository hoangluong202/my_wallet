import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  Future<List<UserData>> getAllUsers() {
    return select(users).get();
  }

  Future<UserData?> getUserById(String id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<UserData?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((tbl) => tbl.email.equals(email))).getSingleOrNull();
  }

  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateUserTimestamp(String id) {
    return (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> deleteUser(String id) {
    return (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<bool> userExists(String id) async {
    final user = await getUserById(id);
    return user != null;
  }
}

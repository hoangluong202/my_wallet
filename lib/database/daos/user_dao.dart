import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(AppDatabase db) : super(db);

  // Get user by ID
  Future<User?> getUserById(String id) {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) {
    return (select(
      users,
    )..where((tbl) => tbl.email.equals(email))).getSingleOrNull();
  }

  // Insert or update user
  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user, mode: InsertMode.insertOrReplace);
  }

  // Update user's updatedAt timestamp
  Future<void> updateUserTimestamp(String id) {
    return (update(users)..where((tbl) => tbl.id.equals(id))).write(
      UsersCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  // Delete user
  Future<int> deleteUser(String id) {
    return (delete(users)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get all users
  Future<List<User>> getAllUsers() {
    return select(users).get();
  }

  // Check if user exists
  Future<bool> userExists(String id) async {
    final user = await getUserById(id);
    return user != null;
  }
}

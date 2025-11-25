import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<User?> getUserByEmail(String email);
  Future<void> saveUser(User user);
  Future<void> updateUserTimestamp(String id);
  Future<void> deleteUser(String id);
  Future<bool> userExists(String id);
  Future<void> syncToCloud(String userId);
  Future<void> pullFromCloud(String userId);
}

import '../../domain/user.dart';

abstract class UserRepository {
  Future<void> saveUser(User user);
  Future<void> updateUserTimestamp(String id);
  Future<void> deleteUser(String id);
  Future<bool> userExists(String id);
}

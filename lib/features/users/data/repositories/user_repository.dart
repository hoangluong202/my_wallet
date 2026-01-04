abstract class UserRepository {
  Future<void> updateUserTimestamp(String id);
  Future<void> deleteUser(String id);
  Future<bool> userExists(String id);
}

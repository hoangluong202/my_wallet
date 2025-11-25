import 'package:drift/drift.dart';
import '../../../../core/local/database/app_database.dart';
import '../../domain/entities/user.dart' as entity;
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;

  UserRepositoryImpl(this._userDao);

  @override
  Future<entity.User?> getUserById(String id) async {
    final userData = await _userDao.getUserById(id);
    if (userData == null) return null;
    return _mapToEntity(userData);
  }

  @override
  Future<entity.User?> getUserByEmail(String email) async {
    final userData = await _userDao.getUserByEmail(email);
    if (userData == null) return null;
    return _mapToEntity(userData);
  }

  @override
  Future<void> saveUser(entity.User user) async {
    final companion = UsersCompanion(
      id: Value(user.id),
      name: Value(user.name),
      email: Value(user.email),
      password: Value(user.password),
      createdAt: Value(user.createdAt),
      updatedAt: Value(user.updatedAt),
    );
    await _userDao.insertUser(companion);
  }

  @override
  Future<void> updateUserTimestamp(String id) async {
    await _userDao.updateUserTimestamp(id);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _userDao.deleteUser(id);
  }

  @override
  Future<bool> userExists(String id) async {
    return await _userDao.userExists(id);
  }

  entity.User _mapToEntity(User data) {
    return entity.User(
      id: data.id,
      name: data.name,
      email: data.email,
      password: data.password,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

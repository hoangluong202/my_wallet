import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import 'user_repository.dart';
import '../../domain/user.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;

  UserRepositoryImpl(this._userDao);
  
  @override
  Future<User?> getUserById(String id) async {
    final userData = await _userDao.getUserById(id);
    return userData != null ? _mapFromDataClass(userData) : null;
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

  @override
  Future<void> saveUser(User user) async {
    await _userDao.insertUser(_mapToCompanion(user));
  }

  UsersCompanion _mapToCompanion(User user) {
    return UsersCompanion(
      id: Value(user.id),
      email: Value(user.email),
      name: Value(user.name),
      password: Value(user.password ?? ''),
      createdAt: Value(user.createdAt),
      updatedAt: Value(user.updatedAt),
    );
  }

  User _mapFromDataClass(UserData data) {
    return User(
      id: data.id,
      email: data.email,
      name: data.name,
      password: data.password.isEmpty ? null : data.password,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}

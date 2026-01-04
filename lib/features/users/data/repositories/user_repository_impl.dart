import '../../../../database/app_database.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;

  UserRepositoryImpl(this._userDao);


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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/user_dao.dart';

abstract class UserFirebaseService {
  Future<void> syncUserToCloud(String userId);
  Future<User?> getUserFromCloud(String userId);
  Future<void> pullUserFromCloud(String userId);
}

class UserFirebaseServiceImpl implements UserFirebaseService {
  final FirebaseFirestore _firestore;
  final UserDao _userDao;
  final firebase_auth.FirebaseAuth _auth;

  UserFirebaseServiceImpl(this._firestore, this._userDao, this._auth);

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference get _usersCollection => _firestore.collection('users');

  void _verifyUserId(String userId) {
    // Verify that the userId matches the authenticated user
    if (_currentUserId != null && _currentUserId != userId) {
      throw Exception(
        'Access denied: userId does not match authenticated user',
      );
    }
  }

  @override
  Future<void> syncUserToCloud(String userId) async {
    _verifyUserId(userId);

    final user = await _userDao.getUserById(userId);
    if (user == null) return;

    final docRef = _usersCollection.doc(userId);
    await docRef.set(_userToMap(user), SetOptions(merge: true));
  }

  @override
  Future<User?> getUserFromCloud(String userId) async {
    _verifyUserId(userId);

    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      return User(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        password: data['password'] as String?,
        createdAt: DateTime.parse(data['createdAt'] as String),
        updatedAt: DateTime.parse(data['updatedAt'] as String),
      );
    } catch (e) {
      throw Exception('Failed to get user from cloud: $e');
    }
  }

  @override
  Future<void> pullUserFromCloud(String userId) async {
    _verifyUserId(userId);

    final cloudUser = await getUserFromCloud(userId);

    if (cloudUser == null) return;

    // Check if user exists locally
    final localUser = await _userDao.getUserById(userId);

    if (localUser == null) {
      // Insert new user from cloud
      await _userDao.insertUser(
        UsersCompanion.insert(
          id: cloudUser.id,
          name: cloudUser.name,
          email: cloudUser.email,
          password: Value(cloudUser.password),
          createdAt: cloudUser.createdAt,
          updatedAt: cloudUser.updatedAt,
        ),
      );
    } else {
      // Update existing user if cloud data is newer
      if (cloudUser.updatedAt.isAfter(localUser.updatedAt)) {
        await _userDao.insertUser(
          UsersCompanion.insert(
            id: cloudUser.id,
            name: cloudUser.name,
            email: cloudUser.email,
            password: Value(cloudUser.password),
            createdAt: cloudUser.createdAt,
            updatedAt: cloudUser.updatedAt,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _userToMap(User user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
  }
}

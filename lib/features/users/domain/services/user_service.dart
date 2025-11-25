import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class UserService {
  final UserRepository _userRepository;

  UserService(this._userRepository);

  /// Handle user login - save or update user info
  Future<User> handleUserLogin(firebase_auth.User firebaseUser) async {
    final userId = firebaseUser.uid;
    final userExists = await _userRepository.userExists(userId);

    if (userExists) {
      // User exists, update timestamp only
      await _userRepository.updateUserTimestamp(userId);
      final user = await _userRepository.getUserById(userId);
      return user!;
    } else {
      // First time login, create new user
      final newUser = User(
        id: userId,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        password: null, // Google sign-in doesn't have password
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userRepository.saveUser(newUser);
      return newUser;
    }
  }

  /// Get current user by ID
  Future<User?> getUser(String id) async {
    return await _userRepository.getUserById(id);
  }

  /// Get user by email
  Future<User?> getUserByEmail(String email) async {
    return await _userRepository.getUserByEmail(email);
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    await _userRepository.deleteUser(id);
  }
}

import 'package:flutter/material.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserViewModel(this._userRepository);

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userName => _currentUser?.name ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getUserById(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Bidirectional sync: Push local user data to cloud, then pull from cloud
  Future<void> bidirectionalSync(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Push local user data to cloud
      await _userRepository.syncToCloud(userId);

      // Step 2: Pull updates from cloud
      await _userRepository.pullFromCloud(userId);

      // Step 3: Reload user data
      await loadUser(userId);
    } catch (e) {
      _error = 'Sync failed: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

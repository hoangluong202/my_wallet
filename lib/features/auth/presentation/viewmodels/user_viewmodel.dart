import 'package:flutter/material.dart';
import '../../domain/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserViewModel(this._userRepository, this._authRepository) {
    _initializeUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userName => _currentUser?.name ?? 'User';
  String get userEmail => _currentUser?.email ?? '';
  String get userId => _currentUser?.id ?? '';

  void _initializeUser() {
    // Listen to auth state changes
    _authRepository.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Load user data from local database
        await _loadCurrentUser(firebaseUser.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadCurrentUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getUserById(userId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
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
}

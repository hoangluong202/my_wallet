import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../users/domain/services/user_service.dart';
import '../../../../core/local/database/app_database.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserService _userService;
  final AppDatabase _database;

  firebase_auth.User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthViewModel(this._authRepository, this._userService, this._database) {
    _initializeAuth();
  }

  // Getters
  firebase_auth.User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  void _initializeAuth() {
    _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authRepository.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;

        // Save or update user in local database
        await _userService.handleUserLogin(user);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Clear all local data (wallets, users, etc.)
      await _database.clearAllData();

      // Sign out from Firebase
      await _authRepository.signOut();

      _currentUser = null;
      _isAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

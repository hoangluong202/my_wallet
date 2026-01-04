import 'package:flutter/material.dart';
import '../../domain/user.dart';

class UserViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserViewModel();

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

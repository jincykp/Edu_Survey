import 'package:edusurvey/data/model/user_model.dart';
import 'package:edusurvey/data/repositories/user_repositories.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user data from SharedPreferences (used when app starts)
  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('user_email');

    if (email != null) {
      _currentUser = await _userRepository.getUserByEmail(email);
      notifyListeners();
    }
  }

  /// Register new user & persist data
  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userRepository.registerUser(name, email, password);
      _currentUser = await _userRepository.getUserByEmail(email);

      if (_currentUser != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', _currentUser!.email);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setBool(
          'isRegistered',
          true,
        ); // Set this flag when user registers
      }
    } catch (e) {
      _errorMessage = "Registration failed: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Login user & persist session
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _userRepository.getUserByEmail(email);

      if (user != null && user.password == password) {
        _currentUser = user;

        // Save login session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email);
        await prefs.setBool('isLoggedIn', true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Invalid email or password";
      }
    } catch (e) {
      _errorMessage = "Login failed: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Update password & persist changes
  Future<bool> updatePassword(String email, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userRepository.updateUserPassword(
        email,
        newPassword,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _userRepository.getUserByEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  /// Logout user & clear session data
  Future<void> signOut() async {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.setBool('isLoggedIn', false);
    // Do NOT clear isRegistered flag during logout
    // This is what keeps the app going to login screen instead of signup
  }
}

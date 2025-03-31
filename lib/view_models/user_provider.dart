import 'package:edusurvey/data/model/user_model.dart';
import 'package:edusurvey/data/repositories/user_repositories.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  UserModel? _currentUser;
  bool _isLoading = false;

  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signUp(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Register user
    await _userRepository.registerUser(name, email, password);

    // Fetch user details from database after registration
    _currentUser = await _userRepository.getUserByEmail(email);

    // Debug: Print user details in console
    if (_currentUser != null) {
      print(
        "User Registered: Name: ${_currentUser!.name}, Email: ${_currentUser!.email}",
      );
    } else {
      print("Error: User not found in the database!");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print("Attempting login for email: $email");

      // Get user from repository
      final user = await _userRepository.getUserByEmail(email);

      print(
        "User retrieved from database: ${user != null ? 'Found' : 'Not found'}",
      );

      if (user != null) {
        print(
          "Database password: ${user.password}, Entered password: $password",
        );
      }

      // Check if user exists and password matches
      if (user != null && user.password == password) {
        _currentUser = user;
        print("Login successful for user: ${user.name}");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = "Invalid email or password";
        print("Login failed: Invalid credentials");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Login error: ${e.toString()}");
      _errorMessage = "An error occurred: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String email, String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _userRepository.updateUserPassword(
        email,
        newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      return await _userRepository.getUserByEmail(email);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

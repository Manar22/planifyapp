//import 'package:flutter/material.dart';

class AuthService {
  // In a real app, this would connect to a backend service
  static final Map<String, String> _users = {};
  static String? _currentUser;

  static bool isSignedIn() {
    return _currentUser != null;
  }

  static String? getCurrentUser() {
    return _currentUser;
  }

  static Future<bool> signIn(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (_users.containsKey(email) && _users[email] == password) {
      _currentUser = email;
      return true;
    }
    return false;
  }

  static Future<bool> signUp(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (_users.containsKey(email)) {
      return false;
    }

    _users[email] = password;
    _currentUser = email;
    return true;
  }

  static void signOut() {
    _currentUser = null;
  }
}

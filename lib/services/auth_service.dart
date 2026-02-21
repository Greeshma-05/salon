import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'users_data';
  String? _currentUserId;

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Initialize - load current user from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString(_currentUserKey);
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        throw Exception('No users registered');
      }

      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      // Find user by email
      final userEntry = users.entries.firstWhere((entry) {
        final userData = Map<String, dynamic>.from(entry.value);
        return userData['email'] == email && userData['password'] == password;
      }, orElse: () => throw Exception('Invalid email or password'));

      final userId = userEntry.key;
      await prefs.setString(_currentUserKey, userId);
      _currentUserId = userId;

      return userId;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'customer',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      final users = usersJson != null
          ? Map<String, dynamic>.from(jsonDecode(usersJson))
          : <String, dynamic>{};

      // Check if email already exists
      final emailExists = users.values.any((userData) {
        final data = Map<String, dynamic>.from(userData);
        return data['email'] == email;
      });

      if (emailExists) {
        throw Exception('Email already registered');
      }

      // Create new user
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final userModel = UserModel(
        uid: userId,
        email: email,
        name: name,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      // Store password separately (in real app, hash this!)
      final userData = userModel.toMap();
      userData['password'] = password;

      users[userId] = userData;
      await prefs.setString(_usersKey, jsonEncode(users));
      await prefs.setString(_currentUserKey, userId);
      _currentUserId = userId;

      return userId;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) return null;

      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      final userData = users[uid];

      if (userData == null) return null;

      final data = Map<String, dynamic>.from(userData);
      data['uid'] = uid;
      return UserModel.fromMap(data);
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    if (_currentUserId == null) {
      await initialize();
    }

    if (_currentUserId == null) return null;

    return getUserData(_currentUserId!);
  }

  // Sign out
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    _currentUserId = null;
  }

  // Reset password (simplified version)
  Future<void> resetPassword(String email) async {
    // In a real app, this would send an email
    // For now, just verify the email exists
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null) {
      throw Exception('No users registered');
    }

    final users = Map<String, dynamic>.from(jsonDecode(usersJson));
    final emailExists = users.values.any((userData) {
      final data = Map<String, dynamic>.from(userData);
      return data['email'] == email;
    });

    if (!emailExists) {
      throw Exception('Email not found');
    }

    // In production, send password reset email
    throw Exception('Password reset functionality not implemented');
  }

  // Update user data (for loyalty points and other updates)
  Future<void> updateUserData(String uid, Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        throw Exception('No users found');
      }

      final users = Map<String, dynamic>.from(jsonDecode(usersJson));
      final userData = users[uid];

      if (userData == null) {
        throw Exception('User not found');
      }

      // Update the user data with new values
      final updatedUserData = Map<String, dynamic>.from(userData);
      updates.forEach((key, value) {
        updatedUserData[key] = value;
      });

      users[uid] = updatedUserData;
      await prefs.setString(_usersKey, jsonEncode(users));
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }
}

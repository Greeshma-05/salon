import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/random_data_generator.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;
  bool _initialized = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userModel != null;
  bool get isAdmin => _userModel?.role == 'admin';

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.initialize();
      final userId = _authService.currentUserId;

      if (userId != null) {
        await _loadUserData(userId);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _userModel = await _authService.getUserData(uid);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _authService.signIn(email, password);
      if (userId != null) {
        await _loadUserData(userId);

        // Generate random appointments for the logged-in user
        await _generateUserAppointments(userId);
      }
      _isLoading = false;
      notifyListeners();
      return userId != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String role = 'customer',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );

      if (userId != null) {
        await _loadUserData(userId);

        // Generate random appointments for new user
        await _generateUserAppointments(userId);
      }

      _isLoading = false;
      notifyListeners();
      return userId != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_userModel != null) {
      await _loadUserData(_userModel!.uid);
    }
  }

  Future<void> _generateUserAppointments(String userId) async {
    try {
      // Generate random appointments for this user (uncomment if needed)
      // await RandomDataGenerator.initializeRandomData(
      //   salonCount: 0,
      //   stylistCount: 0,
      //   treatmentCount: 0,
      //   appointmentCount: 10,
      //   userId: userId,
      // );
      debugPrint('✨ Random appointments can be generated for user: $userId');
    } catch (e) {
      debugPrint('Error generating user appointments: $e');
    }
  }
}

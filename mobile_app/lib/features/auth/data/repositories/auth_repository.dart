import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../sources/local_storage_service.dart';

/// Fully offline AuthRepository — no cloud/API calls.
class AuthRepository {
  final LocalStorageService _localStorage;

  AuthRepository({LocalStorageService? localStorage})
      : _localStorage = localStorage ?? LocalStorageService();

  /// Check local session state for app startup
  Future<Map<String, dynamic>> checkLocalSession() async {
    final session = await _localStorage.getSession();
    if (session != null && session.isLoggedIn) {
      final user = await _localStorage.getUserProfile();
      if (user != null) {
        return {
          'isLoggedIn': true,
          'session': session,
          'user': user,
        };
      }
    }
    return {'isLoggedIn': false};
  }

  /// Register New User — local-only
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    if (fullName.trim().length < AppConstants.minNameLength) {
      throw Exception('Full name must be at least ${AppConstants.minNameLength} characters.');
    }
    if (password.length < AppConstants.minPasswordLength) {
      throw Exception('Password must be at least ${AppConstants.minPasswordLength} characters.');
    }
    if (password != confirmPassword) {
      throw Exception('Passwords do not match.');
    }

    final now = DateTime.now();
    final offlineId = 'user_${now.millisecondsSinceEpoch}';

    final user = UserModel.create(
      id: offlineId,
      email: email.trim(),
      fullName: fullName.trim(),
      phone: phone.trim(),
      updatedAt: now,
    );

    final session = SessionModel.create(
      userId: offlineId,
      authToken: 'local_token_$offlineId',
      isLoggedIn: true,
      lastLoginTime: now,
      lastSyncTime: now,
    );

    await _localStorage.saveSession(session);
    await _localStorage.saveUserProfile(user);

    return user;
  }

  /// Login User — local-only credential check
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final cachedUser = await _localStorage.getUserProfile();

    if (cachedUser != null &&
        cachedUser.email.toLowerCase() == email.trim().toLowerCase()) {
      final now = DateTime.now();
      final session = SessionModel.create(
        userId: cachedUser.id,
        authToken: 'local_token_${cachedUser.id}',
        isLoggedIn: true,
        lastLoginTime: now,
        lastSyncTime: now,
      );
      await _localStorage.saveSession(session);
      return cachedUser;
    }

    // Demo admin shortcut — no password needed in offline mode
    final isAdmin = email.trim().toLowerCase() == 'admin@roadsos.com';
    final now = DateTime.now();
    final offlineId = isAdmin
        ? '00000000-0000-4000-a000-000000000001'
        : 'user_${now.millisecondsSinceEpoch}';

    final user = UserModel.create(
      id: offlineId,
      email: email.trim(),
      fullName: isAdmin ? 'Administrator' : email.split('@').first,
      phone: '',
      role: isAdmin ? 'admin' : 'user',
      updatedAt: now,
    );

    final session = SessionModel.create(
      userId: offlineId,
      authToken: 'local_token_$offlineId',
      isLoggedIn: true,
      lastLoginTime: now,
      lastSyncTime: now,
    );

    await _localStorage.saveSession(session);
    await _localStorage.saveUserProfile(user);

    return user;
  }

  /// Update User Profile — local-only
  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    if (fullName.trim().length < AppConstants.minNameLength) {
      throw Exception('Full Name must be at least ${AppConstants.minNameLength} characters long.');
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      throw Exception('Phone number must be a valid 10-digit mobile number.');
    }

    final currentUser = await _localStorage.getUserProfile();
    if (currentUser == null) {
      throw Exception('Active user session not found.');
    }

    final updatedUser = currentUser.copyWith(
      fullName: fullName.trim(),
      phone: phone.trim(),
      updatedAt: DateTime.now(),
    );

    await _localStorage.saveUserProfile(updatedUser);
    return updatedUser;
  }

  /// Logout User
  Future<void> logout() async {
    await _localStorage.clearSession();
  }
}

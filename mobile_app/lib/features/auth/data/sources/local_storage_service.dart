import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';

/// Local Storage Service for Offline-First Data Persistence
/// Combines Isar Database & SharedPreferences caching.
class LocalStorageService {
  static const String _keySession = 'roadsos_local_session';
  static const String _keyUserProfile = 'roadsos_local_user_profile';
  static const String _keyPendingSync = 'roadsos_pending_sync';
  static const String _keyPendingRegistration = 'roadsos_pending_registration';

  static Isar? _isar;

  /// Lazy Isar Database Initialization
  Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [UserModelSchema, SessionModelSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Save Session locally
  Future<void> saveSession(SessionModel session) async {
    final prefs = await _prefs;
    await prefs.setString(_keySession, jsonEncode(session.toJson()));

    try {
      final isarDb = await db;
      await isarDb.writeTxn(() async {
        await isarDb.collection<SessionModel>().put(session);
      });
    } catch (_) {}
  }

  /// Retrieve local session
  Future<SessionModel?> getSession() async {
    final prefs = await _prefs;
    final String? sessionJson = prefs.getString(_keySession);
    if (sessionJson == null || sessionJson.isEmpty) {
      return null;
    }
    try {
      return SessionModel.fromJson(jsonDecode(sessionJson));
    } catch (_) {
      return null;
    }
  }

  /// Clear local session (on Logout)
  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_keySession);
    await prefs.remove(_keyUserProfile);
    await prefs.remove(_keyPendingSync);
    await prefs.remove(_keyPendingRegistration);

    try {
      final isarDb = await db;
      await isarDb.writeTxn(() async {
        await isarDb.collection<SessionModel>().clear();
        await isarDb.collection<UserModel>().clear();
      });
    } catch (_) {}
  }

  /// Save or update local User Profile
  Future<void> saveUserProfile(UserModel user) async {
    final prefs = await _prefs;
    await prefs.setString(_keyUserProfile, jsonEncode(user.toJson()));

    try {
      final isarDb = await db;
      await isarDb.writeTxn(() async {
        await isarDb.collection<UserModel>().put(user);
      });
    } catch (_) {}
  }

  /// Retrieve local User Profile
  Future<UserModel?> getUserProfile() async {
    final prefs = await _prefs;
    final String? userJson = prefs.getString(_keyUserProfile);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    try {
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  /// Save pending offline registration details
  Future<void> savePendingRegistration(Map<String, dynamic> regData) async {
    final prefs = await _prefs;
    await prefs.setString(_keyPendingRegistration, jsonEncode(regData));
    await prefs.setBool(_keyPendingSync, true);
  }

  /// Get pending registration details
  Future<Map<String, dynamic>?> getPendingRegistration() async {
    final prefs = await _prefs;
    final String? jsonStr = prefs.getString(_keyPendingRegistration);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
  }

  /// Clear pending registration after cloud sync
  Future<void> clearPendingRegistration() async {
    final prefs = await _prefs;
    await prefs.remove(_keyPendingRegistration);
    await prefs.setBool(_keyPendingSync, false);
  }

  /// Flag pending synchronization if profile edited while offline
  Future<void> setPendingSync(bool hasPending) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyPendingSync, hasPending);
  }

  /// Check if offline edits are pending synchronization
  Future<bool> hasPendingSync() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyPendingSync) ?? false;
  }

  /// Update last sync timestamp in session
  Future<void> updateLastSyncTime() async {
    final session = await getSession();
    if (session != null) {
      final updatedSession = session.copyWith(lastSyncTime: DateTime.now());
      await saveSession(updatedSession);
      await setPendingSync(false);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/models/session_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/sources/local_storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final SessionModel? session;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.session,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    SessionModel? session,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  AuthNotifier({
    AuthRepository? authRepository,
    LocalStorageService? localStorage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _localStorage = localStorage ?? LocalStorageService(),
        super(const AuthState(status: AuthStatus.initial));

  /// App Boot session verification (Offline/Local)
  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final sessionData = await _authRepository.checkLocalSession();

      if (sessionData['isLoggedIn'] == true) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: sessionData['user'],
          session: sessionData['session'],
        );
      } else {
        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  /// Register New User
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );

      final session = await _localStorage.getSession();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Login User
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );

      final session = await _localStorage.getSession();

      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
        session: session,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Update Profile (Editable: Full Name, Phone)
  Future<bool> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final previousUser = state.user;
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: fullName,
        phone: phone,
      );

      final updatedSession = await _localStorage.getSession();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
        session: updatedSession,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: previousUser,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  /// Forgot Password (Local mode notification)
  Future<String> forgotPassword(String email) async {
    return 'Password reset requested locally for $email.';
  }

  /// Logout User
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authRepository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

// Global Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final localStorageProvider = Provider<LocalStorageService>((ref) => LocalStorageService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
    localStorage: ref.watch(localStorageProvider),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/storage/session_storage.dart';
import '../models/auth_state.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  return AuthNotifier(repository, sessionStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SessionStorage _sessionStorage;

  AuthNotifier(this._repository, this._sessionStorage)
      : super(const AuthState(status: AuthStatus.initial)) {
    checkAuthSession();
  }

  Future<void> checkAuthSession() async {
    final token = _sessionStorage.getToken();
    final cachedUserMap = _sessionStorage.getUser();

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
      );
      return;
    }

    // A token exists. Verify token validity against the backend.
    // Do not treat cached profile as proof the token is still valid.
    try {
      final user = await _repository.getMe();
      await _sessionStorage.saveUser(user.toMap());
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        clearError: true,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.code == 'TOKEN_EXPIRED' || e.code == 'UNAUTHORIZED') {
        // Token was rejected by backend
        await _sessionStorage.clearSession();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearToken: true,
          errorMessage: 'Your session has expired. Please sign in again.',
        );
      } else if (e.code == 'NETWORK_ERROR' || e.code == 'TIMEOUT') {
        // Network unavailable - if cached user exists, allow offline session
        if (cachedUserMap != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: UserModel.fromMap(cachedUserMap),
            token: token,
            isOfflineMode: true,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Unable to connect to server. Running offline.',
            isOfflineMode: true,
          );
        }
      } else {
        await _sessionStorage.clearSession();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUser: true,
          clearToken: true,
        );
      }
    } catch (_) {
      await _sessionStorage.clearSession();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearError: true,
    );

    try {
      final result = await _repository.register(
        email: email,
        password: password,
        name: name,
      );

      await _sessionStorage.saveToken(result.token);
      await _sessionStorage.saveUser(result.user.toMap());

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        token: result.token,
        isOfflineMode: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected registration error occurred.',
      );
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearError: true,
    );

    try {
      final result = await _repository.login(
        email: email,
        password: password,
      );

      await _sessionStorage.saveToken(result.token);
      await _sessionStorage.saveUser(result.user.toMap());

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.user,
        token: result.token,
        isOfflineMode: false,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected sign in error occurred.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _sessionStorage.clearSession();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      isOfflineMode: false,
    );
  }

  void continueOffline() {
    state = state.copyWith(
      isOfflineMode: true,
      clearError: true,
    );
  }
}

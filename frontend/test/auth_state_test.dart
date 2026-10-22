import 'package:flutter_test/flutter_test.dart';
import 'package:habitflow_pro/features/auth/models/auth_state.dart';
import 'package:habitflow_pro/features/auth/models/user_model.dart';

void main() {
  group('AuthState Model Tests', () {
    test('initial state should be unauthenticated with no token', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.token, isNull);
    });

    test('authenticated state should report isAuthenticated = true when token is present', () {
      const user = UserModel(
        id: 'u1',
        email: 'alex@habitflow.pro',
        name: 'Alex Rivera',
      );

      final state = const AuthState().copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: 'sample.jwt.token',
      );

      expect(state.isAuthenticated, true);
      expect(state.user?.name, 'Alex Rivera');
      expect(state.token, 'sample.jwt.token');
    });

    test('clearUser and clearToken should safely reset sensitive session values', () {
      const user = UserModel(
        id: 'u1',
        email: 'alex@habitflow.pro',
        name: 'Alex Rivera',
      );

      final loggedInState = const AuthState(
        status: AuthStatus.authenticated,
        user: user,
        token: 'sample.jwt.token',
      );

      final loggedOutState = loggedInState.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        clearToken: true,
      );

      expect(loggedOutState.isAuthenticated, false);
      expect(loggedOutState.user, isNull);
      expect(loggedOutState.token, isNull);
      expect(loggedOutState.status, AuthStatus.unauthenticated);
    });
  });
}

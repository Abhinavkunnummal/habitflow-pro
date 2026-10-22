import '../../../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthResult {
  final UserModel user;
  final String token;

  const AuthResult({
    required this.user,
    required this.token,
  });
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    String? avatarUrl,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
        'name': name.trim(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );

    final data = response as Map<String, dynamic>;
    final user = UserModel.fromMap(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    return AuthResult(user: user, token: token);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = response as Map<String, dynamic>;
    final user = UserModel.fromMap(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;

    return AuthResult(user: user, token: token);
  }

  Future<UserModel> getMe() async {
    final response = await _apiClient.get('/auth/me');
    final data = response as Map<String, dynamic>;
    return UserModel.fromMap(data['user'] as Map<String, dynamic>);
  }
}

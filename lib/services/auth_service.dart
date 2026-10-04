import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final ApiClient _client = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';

  Future<AppUser> login(String username, String password) async {
    final response = await _client.post(
      'api/auth/login',
      body: {'username': username, 'password': password},
    );

    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.write(key: _tokenKey, value: token);
    _client.setToken(token);

    return user;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    _client.setToken(null);
  }

  Future<String?> restoreToken() async {
    final token = await _storage.read(key: _tokenKey);
    _client.setToken(token);
    return token;
  }
}

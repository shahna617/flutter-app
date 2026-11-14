import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../session/session_provider.dart';

/// Result of a successful login.
class AuthResult {
  final String token;
  final UserRole role;

  const AuthResult({required this.token, required this.role});
}

/// Error with a message that is safe to show to the user.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Handles login, logout and saving the token on the phone.
///
/// Agreed API (confirm with Person 1):
///   POST /api/auth/login/   {"username", "password"} -> {"token", "role"}
///   POST /api/auth/logout/  header `Authorization: Token <token>`
class AuthService {
  AuthService({http.Client? client, FlutterSecureStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _client;
  final FlutterSecureStorage _storage;

  // 10.0.2.2 is how the Android emulator reaches your computer's localhost.
  // Override with: flutter run --dart-define=API_BASE_URL=https://your-app.onrender.com
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';

  /// Logs in, saves the token, and returns the token and role.
  Future<AuthResult> login(String username, String password) async {
    final http.Response response;
    try {
      response = await _client
          .post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw const AuthException('The server took too long to respond.');
    } catch (_) {
      throw const AuthException('Cannot reach the server. Check your internet.');
    }

    if (response.statusCode == 400 || response.statusCode == 401) {
      throw const AuthException('Invalid username or password.');
    }
    if (response.statusCode != 200) {
      throw AuthException('Server error (${response.statusCode}).');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    final role = _parseRole(data['role'] as String?);
    if (token == null || role == null) {
      throw const AuthException('Unexpected response from the server.');
    }

    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role.name);
    return AuthResult(token: token, role: role);
  }

  /// Returns the saved login (if any) so the user stays logged in.
  Future<AuthResult?> loadSavedLogin() async {
    final token = await _storage.read(key: _tokenKey);
    final role = _parseRole(await _storage.read(key: _roleKey));
    if (token == null || role == null) return null;
    return AuthResult(token: token, role: role);
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Logs out. Tells the server (best effort), then always clears the phone.
  Future<void> logout() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      try {
        await _client
            .post(
          Uri.parse('$baseUrl/api/auth/logout/'),
          headers: {'Authorization': 'Token $token'},
        )
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Ignore: the user is logged out on this phone either way.
      }
    }
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }

  UserRole? _parseRole(String? value) {
    switch (value) {
      case 'student':
        return UserRole.student;
      case 'admin':
        return UserRole.admin;
      default:
        return null;
    }
  }
}
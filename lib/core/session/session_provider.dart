import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';

/// Supported user roles for Guardly mobile application.
enum UserRole {
  student,
  admin,
}

/// Holds the logged-in user's token and role.
///
/// Login and logout go through [AuthService]. [RoleGate] watches this
/// provider, so it shows the right screen as soon as the role changes.
class SessionProvider extends ChangeNotifier {
  SessionProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  UserRole? _role;
  String? _token;
  bool _isRestoring = true;

  UserRole? get role => _role;
  String? get token => _token;

  /// True while the app checks for a saved login at startup.
  bool get isRestoring => _isRestoring;

  bool get isLoggedIn => _role != null;

  /// Loads a saved login from the phone (call once at app start).
  Future<void> restore() async {
    final saved = await _authService.loadSavedLogin();
    if (saved != null) {
      _token = saved.token;
      _role = saved.role;
    }
    _isRestoring = false;
    notifyListeners();
  }

  /// Real login. Throws [AuthException] with a message safe to show.
  Future<void> login(String username, String password) async {
    final result = await _authService.login(username, password);
    _token = result.token;
    _role = result.role;
    notifyListeners();
  }

  /// Dev-only: used by the temporary role picker. Remove later.
  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _role = null;
    notifyListeners();
  }
}
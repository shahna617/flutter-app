import 'package:flutter/foundation.dart';

/// Supported user roles for Guardly mobile application.
enum UserRole {
  student,
  admin,
}

/// In-memory session provider holding user role and auth state.
///
/// NOTE: The authentication task will replace this in-memory role source
/// with the real token/login response.
class SessionProvider extends ChangeNotifier {
  UserRole? _role;

  UserRole? get role => _role;

  bool get isLoggedIn => _role != null;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  void logout() {
    _role = null;
    notifyListeners();
  }
}

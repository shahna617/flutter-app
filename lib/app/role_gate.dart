import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session/session_provider.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/login_screen.dart';
import '../screens/student/student_shell.dart';

/// Role-based router: shows the login screen, or the shell for the user's role.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    // Checking for a saved login at app start.
    if (session.isRestoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (session.role) {
      case UserRole.student:
        return const StudentShell();
      case UserRole.admin:
        return const AdminShell();
      case null:
        return const LoginScreen();
    }
  }
}
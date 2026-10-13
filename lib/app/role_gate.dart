import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session/session_provider.dart';
import '../screens/admin/admin_shell.dart';
import '../screens/student/student_shell.dart';
import 'dev_role_picker_screen.dart';

/// Role-based router directing user to the corresponding shell or dev role picker.
class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();

    switch (session.role) {
      case UserRole.student:
        return const StudentShell();
      case UserRole.admin:
        return const AdminShell();
      case null:
        return const DevRolePickerScreen();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/auth/auth_service.dart';
import '../core/session/session_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/primary_button.dart';

/// Login screen. Follows DESIGN.md: shared scaffold, glass card, theme tokens only.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _waking = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your username and password.');
      return;
    }

    setState(() {
      _loading = true;
      _waking = true;
      _error = null;
    });

    final session = context.read<SessionProvider>();
    try {
      // On success RoleGate swaps this screen for the right shell.
      await session.login(username, password);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _waking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionProvider>();

    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.s24),
          Text('Guardly', style: AppTextStyles.greeting),
          const SizedBox(height: AppSpacing.s4),
          Text('Log in to continue', style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.s24),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  label: 'Username',
                  controller: _usernameController,
                  enabled: !_loading,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.s16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  enabled: !_loading,
                  obscureText: true,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.s20),
                PrimaryButton(
                  label: 'Log in',
                  onPressed: _submit,
                  loading: _loading,
                ),
                if (_waking && _error == null) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    'Waking up the server, this can take up to a minute.',
                    style: AppTextStyles.bodyMuted,
                  ),
                ] else if (_error != null) ...[
                  const SizedBox(height: AppSpacing.s12),
                  Text(
                    _error!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.s24),
            Text(
              'Debug only',
              textAlign: TextAlign.center,
              style: AppTextStyles.meta,
            ),
            const SizedBox(height: AppSpacing.s8),
            TextButton(
              onPressed: () => session.setRole(UserRole.student),
              child: Text(
                'Dev: enter as Student',
                style: AppTextStyles.chip,
              ),
            ),
            TextButton(
              onPressed: () => session.setRole(UserRole.admin),
              child: Text(
                'Dev: enter as Admin',
                style: AppTextStyles.chip,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
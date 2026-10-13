import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/session/session_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/glass_card.dart';

/// Temporary development screen to switch roles.
///
/// NOTE: This screen is temporary and will be replaced by the real login screen
/// when the authentication module is implemented.
class DevRolePickerScreen extends StatelessWidget {
  const DevRolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(
                  Icons.shield_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Guardly',
                textAlign: TextAlign.center,
                style: AppTextStyles.greeting.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Development Role Selector',
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Select a user role to explore the corresponding app shell and navigation.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.s24),
              _DevRoleButton(
                label: 'Continue as Student',
                icon: Icons.school_outlined,
                onPressed: () {
                  context.read<SessionProvider>().setRole(UserRole.student);
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              _DevRoleButton(
                label: 'Continue as Admin',
                icon: Icons.admin_panel_settings_outlined,
                onPressed: () {
                  context.read<SessionProvider>().setRole(UserRole.admin);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevRoleButton extends StatelessWidget {
  const _DevRoleButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
          ),
        ),
        icon: Icon(
          icon,
          size: 20,
          color: AppColors.onPrimary,
        ),
        label: Text(
          label,
          style: AppTextStyles.button,
        ),
      ),
    );
  }
}

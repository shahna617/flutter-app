import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable App Header component defined in DESIGN.md section 7.
/// Displays the shield logo and "Guardly" title on the left, and the role chip on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.roleName,
    this.onLogout,
  });

  final String roleName;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primary,
                size: 26,
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'Guardly',
                style: AppTextStyles.screenTitle.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  roleName,
                  style: AppTextStyles.chip,
                ),
              ),
              if (onLogout != null) ...[
                const SizedBox(width: AppSpacing.s8),
                IconButton(
                  onPressed: onLogout,
                  tooltip: 'Log out',
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

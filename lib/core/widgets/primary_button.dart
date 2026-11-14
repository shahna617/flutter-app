import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Primary action button from DESIGN.md section 7: height 52, full width,
/// pill shape, primary fill, optional leading icon. Max one per card.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Shows a spinner and disables the button while true.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
        ),
        child: loading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.onPrimary,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.s8),
            ],
            Text(label, style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }
}
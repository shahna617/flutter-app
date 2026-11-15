import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable dropdown field styled consistently with [AppTextField]:
/// label above, white 60% fill, radius 16, 1px border, focus border primary.
/// Built on top of [DropdownButtonFormField<String>].
class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.hint,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final List<String> items;
  final String? value;
  final String? hint;
  final ValueChanged<String?>? onChanged;
  final bool enabled;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.inner),
    borderSide: BorderSide(color: color, width: 1),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.meta),
        const SizedBox(height: AppSpacing.s8),
        DropdownButtonFormField<String>(
          key: ValueKey(value),
          initialValue: value,
          hint: hint != null ? Text(hint!, style: AppTextStyles.bodyMuted) : null,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: AppTextStyles.body),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.inner),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            disabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

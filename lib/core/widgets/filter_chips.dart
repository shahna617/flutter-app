import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Horizontally scrollable row of filter chips defined in DESIGN.md section 7.
/// Selected chip has a primarySoft background with primary text (600).
/// Unselected chips have a transparent background with a subtle border.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  /// The list of filter options to display.
  final List<String> options;

  /// The currently active filter option.
  final String selected;

  /// Callback triggered when a filter option is selected.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.s8),
            _buildChip(options[i]),
          ],
        ],
      ),
    );
  }

  /// Builds an individual pill chip.
  Widget _buildChip(String option) {
    final isSelected = option == selected;

    return Material(
      color: isSelected ? AppColors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => onSelected(option),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: isSelected ? AppColors.primarySoft : AppColors.border,
            ),
          ),
          child: Text(
            option,
            style: AppTextStyles.chip.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

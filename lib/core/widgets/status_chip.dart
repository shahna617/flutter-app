import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Style variants for the status chip defined in DESIGN.md sections 2 & 7.
enum StatusChipStyle {
  pending,
  inReview,
  resolved,
  rejected,
}

/// Helper function to map a backend status string to a [StatusChipStyle].
StatusChipStyle statusChipStyleFromString(String status) {
  switch (status.trim().toLowerCase()) {
    case 'under review':
    case 'pending rejection':
      return StatusChipStyle.inReview;
    case 'resolved':
      return StatusChipStyle.resolved;
    case 'rejected':
      return StatusChipStyle.rejected;
    case 'pending':
    default:
      return StatusChipStyle.pending;
  }
}

/// Compact pill chip showing incident report status.
/// Implements DESIGN.md section 7 & section 2 colors (padding 12x5, 12/600 text).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.style = StatusChipStyle.pending,
  });

  /// Factory constructor that automatically chooses the style from a status string.
  factory StatusChip.fromStatus(String status) {
    return StatusChip(
      label: status,
      style: statusChipStyleFromString(status),
    );
  }

  /// Text displayed inside the chip (from backend).
  final String label;

  /// Visual style variant of the chip.
  final StatusChipStyle style;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    final Color? borderColor;

    switch (style) {
      case StatusChipStyle.pending:
        backgroundColor = AppColors.pendingBg;
        textColor = AppColors.pendingText;
        borderColor = null;
      case StatusChipStyle.inReview:
        backgroundColor = AppColors.inReviewBg;
        textColor = AppColors.inReviewText;
        borderColor = null;
      case StatusChipStyle.resolved:
        backgroundColor = AppColors.resolvedBg;
        textColor = AppColors.resolvedText;
        borderColor = null;
      case StatusChipStyle.rejected:
        // Transparent background with danger text and border per DESIGN.md
        backgroundColor = Colors.transparent;
        textColor = AppColors.danger;
        borderColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(
        label,
        style: AppTextStyles.chip.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';
import 'status_chip.dart';

/// Report card widget adhering to DESIGN.md sections 7 & 10.
///
/// Features a GlassCard with:
/// - Top line: ID (e.g. "#12") and date in meta style on the left, StatusChip on the right
/// - Bottom line: Category title (16/600) and location (muted), with chevron on the right
/// - Entire card is tappable via [onTap].
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.id,
    required this.date,
    required this.category,
    required this.location,
    required this.status,
    this.statusStyle,
    this.onTap,
  });

  /// Report ID number or string (e.g. 12 or "#12").
  final String id;

  /// Formatted date string (e.g. "14 Nov").
  final String date;

  /// Category name displayed as the card title (16/600).
  final String category;

  /// Incident location text.
  final String location;

  /// Status text from server (e.g. "Pending", "Under Review", etc.).
  final String status;

  /// Optional style override for [StatusChip].
  final StatusChipStyle? statusStyle;

  /// Optional callback when card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Format ID with a leading '#' if not already present
    final formattedId = id.startsWith('#') ? id : '#$id';

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top line: ID and date on left, StatusChip on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '$formattedId · $date',
                  style: AppTextStyles.meta,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              StatusChip(
                label: status,
                style: statusStyle ?? statusChipStyleFromString(status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.cardInnerGap),

          // Main line: category title, location, and chevron on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      location,
                      style: AppTextStyles.meta,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

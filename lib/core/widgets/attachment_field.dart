import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'outline_button.dart';

/// Available sources for selecting a photo or video attachment.
enum AttachmentSource {
  cameraPhoto,
  galleryPhoto,
  cameraVideo,
  galleryVideo,
}

/// A form field widget for attaching a single photo or video.
/// Follows DESIGN.md: strict 4/8 spacing, glass bottom sheet, outline icons.
class AttachmentField extends StatelessWidget {
  const AttachmentField({
    super.key,
    required this.label,
    this.filePath,
    this.isVideo = false,
    required this.onPick,
    required this.onRemove,
    this.enabled = true,
  });

  /// The label displayed above the field.
  final String label;

  /// The local file path of the currently selected attachment, or null if none.
  final String? filePath;

  /// Whether the attachment is a video (true) or photo (false).
  final bool isVideo;

  /// Callback when the user selects a source option from the bottom sheet.
  final void Function(AttachmentSource source) onPick;

  /// Callback when the user taps the remove button.
  final VoidCallback onRemove;

  /// Whether the field is interactive.
  final bool enabled;

  /// Extracts the base file name from a file path.
  String _getFileName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }

  /// Displays the modal bottom sheet to choose an attachment source.
  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: Colors.white.withValues(alpha: 0.90),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.s16,
                horizontal: AppSpacing.s20,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Small drag handle
                    Container(
                      width: 36,
                      height: AppSpacing.s4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    _PickerOptionRow(
                      icon: Icons.photo_camera_outlined,
                      title: 'Take a photo',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onPick(AttachmentSource.cameraPhoto);
                      },
                    ),
                    _PickerOptionRow(
                      icon: Icons.photo_library_outlined,
                      title: 'Choose a photo',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onPick(AttachmentSource.galleryPhoto);
                      },
                    ),
                    _PickerOptionRow(
                      icon: Icons.videocam_outlined,
                      title: 'Record a video',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onPick(AttachmentSource.cameraVideo);
                      },
                    ),
                    _PickerOptionRow(
                      icon: Icons.video_library_outlined,
                      title: 'Choose a video',
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        onPick(AttachmentSource.galleryVideo);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = filePath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label matching AppTextField style
        Text(label, style: AppTextStyles.meta),
        const SizedBox(height: AppSpacing.s8),

        if (currentPath == null || currentPath.isEmpty)
          // Button to open the attachment picker
          OutlineButton(
            label: 'Add photo or video',
            icon: Icons.add_photo_alternate_outlined,
            onPressed: enabled ? () => _showPickerSheet(context) : null,
          )
        else
          // Attachment preview row inside a rounded box
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppRadius.inner),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: Row(
              children: [
                // 64x64 thumbnail
                SizedBox(
                  width: 64,
                  height: 64,
                  child: isVideo
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.inner),
                          ),
                          child: const Icon(
                            Icons.videocam_outlined,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.inner),
                          child: Image.file(
                            File(currentPath),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.primarySoft,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.s12),

                // File name (size 13, single line, ellipsis)
                Expanded(
                  child: Text(
                    _getFileName(currentPath),
                    style: AppTextStyles.body.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),

                // Remove icon button with 44x44 tap target
                SizedBox(
                  width: AppSpacing.minTapTarget,
                  height: AppSpacing.minTapTarget,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onPressed: enabled ? onRemove : null,
                    tooltip: 'Remove attachment',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A single 52-high picker option row with outline icon and min 44 tap target.
class _PickerOptionRow extends StatelessWidget {
  const _PickerOptionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.inner),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(width: AppSpacing.s12),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

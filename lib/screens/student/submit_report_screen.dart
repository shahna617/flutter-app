import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/report_options.dart';
import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/attachment_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/incident_service.dart';
import '../../services/permissions_service.dart';

/// Screen for students to submit an incident report.
/// Follows DESIGN.md: glass card form, shared theme tokens and widgets only.
class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    super.key,
    IncidentService? incidentService,
    PermissionsService? permissionsService,
    ImagePicker? imagePicker,
  })  : _incidentService = incidentService,
        _permissionsService = permissionsService,
        _imagePicker = imagePicker;

  final IncidentService? _incidentService;
  final PermissionsService? _permissionsService;
  final ImagePicker? _imagePicker;

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  late final IncidentService _incidentService;
  late final PermissionsService _permissionsService;
  late final ImagePicker _imagePicker;
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isAnonymous = false;
  bool _loading = false;
  bool _uploading = false;
  String? _errorMessage;
  bool _permissionPermanentlyDenied = false;

  String? _attachmentPath;
  bool _attachmentIsVideo = false;
  String? _uploadedUrl;

  @override
  void initState() {
    super.initState();
    _incidentService = widget._incidentService ?? IncidentService();
    _permissionsService = widget._permissionsService ?? PermissionsService();
    _imagePicker = widget._imagePicker ?? ImagePicker();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Opens camera or gallery based on the chosen [source] and validates the selection.
  Future<void> _handlePickAttachment(AttachmentSource source) async {
    FocusScope.of(context).unfocus();

    // Camera sources require camera permission before opening
    if (source == AttachmentSource.cameraPhoto ||
        source == AttachmentSource.cameraVideo) {
      final permission = await _permissionsService.requestCamera();
      if (!mounted) return;

      if (permission == AppPermissionResult.denied) {
        setState(() {
          _errorMessage = 'Camera permission is needed to use the camera.';
          _permissionPermanentlyDenied = false;
        });
        return;
      } else if (permission == AppPermissionResult.permanentlyDenied) {
        setState(() {
          _errorMessage = 'Camera permission is needed to use the camera.';
          _permissionPermanentlyDenied = true;
        });
        return;
      }
    }

    final XFile? pickedFile;
    try {
      switch (source) {
        case AttachmentSource.cameraPhoto:
          pickedFile = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 80,
          );
          break;
        case AttachmentSource.galleryPhoto:
          pickedFile = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1600,
            maxHeight: 1600,
            imageQuality: 80,
          );
          break;
        case AttachmentSource.cameraVideo:
          pickedFile = await _imagePicker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 1),
          );
          break;
        case AttachmentSource.galleryVideo:
          pickedFile = await _imagePicker.pickVideo(
            source: ImageSource.gallery,
            maxDuration: const Duration(minutes: 1),
          );
          break;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not open the camera or gallery.';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    if (!mounted) return;

    // If the user cancelled the picker, do nothing
    if (pickedFile == null) {
      return;
    }

    final path = pickedFile.path;

    // Validate file extension (case-insensitive)
    final lastDot = path.lastIndexOf('.');
    final extension =
        lastDot != -1 ? path.substring(lastDot).toLowerCase() : '';
    const allowedExtensions = {
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.mp4',
      '.mov',
    };
    if (!allowedExtensions.contains(extension)) {
      setState(() {
        _errorMessage =
            'Only photos (JPEG, PNG, WebP) and videos (MP4, MOV) are allowed.';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    // Validate file size (at most 50 MB)
    final file = File(path);
    final int fileSize;
    try {
      fileSize = await file.length();
    } catch (_) {
      setState(() {
        _errorMessage = 'Could not read the selected file.';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    if (fileSize > 50 * 1024 * 1024) {
      setState(() {
        _errorMessage = 'File is too large (50 MB maximum).';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    final isVideo = extension == '.mp4' || extension == '.mov';

    setState(() {
      _attachmentPath = path;
      _attachmentIsVideo = isVideo;
      _uploadedUrl = null; // Clear remembered URL when attachment changes
      _errorMessage = null;
      _permissionPermanentlyDenied = false;
    });
  }

  /// Removes the current attachment and clears the remembered upload URL.
  void _removeAttachment() {
    setState(() {
      _attachmentPath = null;
      _attachmentIsVideo = false;
      _uploadedUrl = null;
      _errorMessage = null;
      _permissionPermanentlyDenied = false;
    });
  }

  /// Validates inputs and submits the incident report to the backend.
  Future<void> _submitReport() async {
    // Hide keyboard before submitting
    FocusScope.of(context).unfocus();

    final category = _selectedCategory;
    final location = _selectedLocation;
    final description = _descriptionController.text.trim();

    // Required fields validation
    if (category == null ||
        category.isEmpty ||
        location == null ||
        location.isEmpty ||
        description.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    final token = context.read<SessionProvider>().token;
    if (token == null) {
      setState(() {
        _errorMessage = 'You must be logged in to submit a report.';
        _permissionPermanentlyDenied = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _permissionPermanentlyDenied = false;
    });

    // If an attachment is selected, upload it first (or reuse remembered URL)
    String? imageUrl = _uploadedUrl;
    if (_attachmentPath != null && imageUrl == null) {
      setState(() {
        _uploading = true;
      });

      try {
        imageUrl = await _incidentService.uploadMedia(
          token: token,
          filePath: _attachmentPath!,
        );
        if (!mounted) return;
        _uploadedUrl = imageUrl;
      } on IncidentException catch (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = e.message;
          _loading = false;
          _uploading = false;
        });
        return; // Do NOT create the report if upload fails
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Cannot reach the server. Please try again.';
          _loading = false;
          _uploading = false;
        });
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _uploading = false;
    });

    // Submit the incident report
    try {
      await _incidentService.createIncident(
        token: token,
        category: category,
        description: description,
        locationText: location,
        isAnonymous: _isAnonymous,
        imageUrl: imageUrl,
      );

      // Check if widget is still mounted after network request
      if (!mounted) return;

      // Reset form fields on successful submission
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedLocation = null;
        _isAnonymous = false;
        _attachmentPath = null;
        _attachmentIsVideo = false;
        _uploadedUrl = null;
        _errorMessage = null;
        _permissionPermanentlyDenied = false;
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted'),
        ),
      );
    } on IncidentException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Cannot reach the server. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String submitButtonLabel;
    if (_uploading) {
      submitButtonLabel = 'Uploading...';
    } else if (_loading) {
      submitButtonLabel = 'Submitting...';
    } else {
      submitButtonLabel = 'Submit report';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Submit a report',
          style: AppTextStyles.screenTitle,
        ),
        const SizedBox(height: AppSpacing.s4),
        Text(
          'Report safety issues or incidents on campus.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.s16),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category dropdown
              AppDropdownField(
                label: 'Category',
                hint: 'Select category',
                items: reportCategories,
                value: _selectedCategory,
                enabled: !_loading,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.s16),

              // Description input (multiline)
              AppTextField(
                label: 'Description',
                controller: _descriptionController,
                enabled: !_loading,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Location dropdown
              AppDropdownField(
                label: 'Location',
                hint: 'Select location',
                items: reportLocations,
                value: _selectedLocation,
                enabled: !_loading,
                onChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.s16),

              // Attachment field (photo or video)
              AttachmentField(
                label: 'Photo or video (optional)',
                filePath: _attachmentPath,
                isVideo: _attachmentIsVideo,
                enabled: !_loading,
                onPick: _handlePickAttachment,
                onRemove: _removeAttachment,
              ),
              const SizedBox(height: AppSpacing.s16),

              // Anonymous toggle row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit anonymously',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Your name is hidden from admins in the report list.',
                          style: AppTextStyles.meta,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Switch(
                    value: _isAnonymous,
                    activeTrackColor: AppColors.primary,
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() {
                              _isAnonymous = value;
                            });
                          },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Submit button
              PrimaryButton(
                label: submitButtonLabel,
                onPressed: _loading ? null : _submitReport,
                loading: _loading,
              ),

              // Error display inside the card
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.s12),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                  ),
                ),
                if (_permissionPermanentlyDenied) ...[
                  const SizedBox(height: AppSpacing.s4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _permissionsService.openSettings(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8,
                          vertical: AppSpacing.s4,
                        ),
                        minimumSize: const Size(
                          AppSpacing.minTapTarget,
                          AppSpacing.minTapTarget,
                        ),
                      ),
                      child: Text(
                        'Open settings',
                        style: AppTextStyles.meta.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

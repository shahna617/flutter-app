import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/report_options.dart';
import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/incident_service.dart';

/// Screen for students to submit an incident report.
/// Follows DESIGN.md: glass card form, shared theme tokens and widgets only.
class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    super.key,
    IncidentService? incidentService,
  }) : _incidentService = incidentService;

  final IncidentService? _incidentService;

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  late final IncidentService _incidentService;
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLocation;
  bool _isAnonymous = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _incidentService = widget._incidentService ?? IncidentService();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
      });
      return;
    }

    final token = context.read<SessionProvider>().token;
    if (token == null) {
      setState(() {
        _errorMessage = 'You must be logged in to submit a report.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _incidentService.createIncident(
        token: token,
        category: category,
        description: description,
        locationText: location,
        isAnonymous: _isAnonymous,
      );

      // Check if widget is still mounted after network request
      if (!mounted) return;

      // Reset form fields on successful submission
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedLocation = null;
        _isAnonymous = false;
        _errorMessage = null;
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                label: 'Submit report',
                onPressed: _submitReport,
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
              ],
            ],
          ),
        ),
      ],
    );
  }
}

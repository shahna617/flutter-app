import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/filter_chips.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/outline_button.dart';
import '../../core/widgets/report_card.dart';
import '../../core/widgets/status_chip.dart';
import '../../services/incident_service.dart';

/// Screen for students to view their submitted incident reports.
/// Adheres strictly to DESIGN.md sections 7, 10, and 11.
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({
    super.key,
    required this.isActive,
    required this.onSubmitNew,
    this.incidentService,
  });

  /// Whether this tab is currently the active tab in the student shell.
  final bool isActive;

  /// Callback to navigate to the Submit report tab.
  final VoidCallback onSubmitNew;

  /// Incident service instance (can be injected for testing).
  final IncidentService? incidentService;

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  late final IncidentService _incidentService;

  static const List<String> _filters = [
    'All',
    'Pending',
    'In review',
    'Resolved',
  ];

  String _selectedFilter = 'All';
  List<Incident> _incidents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _incidentService = widget.incidentService ?? IncidentService();
    _loadIncidents();
  }

  @override
  void didUpdateWidget(covariant MyReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload when student switches to this tab
    if (!oldWidget.isActive && widget.isActive) {
      _loadIncidents();
    }
  }

  /// Fetches incidents for the currently logged-in student.
  Future<void> _loadIncidents() async {
    final token = context.read<SessionProvider>().token;
    if (token == null) {
      setState(() {
        _errorMessage = 'You must be logged in to view your reports.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final incidents = await _incidentService.fetchMyIncidents(token: token);
      if (!mounted) return;
      setState(() {
        _incidents = incidents;
        _isLoading = false;
        _errorMessage = null;
      });
    } on IncidentException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Cannot reach the server. Please try again.';
        _isLoading = false;
      });
    }
  }

  /// Filters incidents based on the selected filter chip.
  /// "Rejected" reports only appear under All.
  List<Incident> _filterIncidents(List<Incident> incidents) {
    switch (_selectedFilter) {
      case 'Pending':
        return incidents
            .where((i) => i.status.trim().toLowerCase() == 'pending')
            .toList();
      case 'In review':
        return incidents.where((i) {
          final s = i.status.trim().toLowerCase();
          return s == 'under review' || s == 'pending rejection';
        }).toList();
      case 'Resolved':
        return incidents
            .where((i) => i.status.trim().toLowerCase() == 'resolved')
            .toList();
      case 'All':
      default:
        return incidents;
    }
  }

  /// Formats date as "14 Nov" in local time without external packages.
  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${local.day} ${months[local.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Your reports, in one place',
          style: AppTextStyles.screenTitle,
        ),
        const SizedBox(height: AppSpacing.s4),

        // Subtitle (15 muted)
        Text(
          'Track the status of incidents you reported.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Horizontal filter chips
        FilterChips(
          options: _filters,
          selected: _selectedFilter,
          onSelected: (filter) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // Body content based on state (Loading, Error, Empty, or List)
        _buildContent(),
      ],
    );
  }

  /// Builds the main content area depending on the current state.
  Widget _buildContent() {
    // 1. Loading state: 3 skeleton GlassCards per DESIGN.md section 11
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    // 2. Error state: one plain sentence in danger color inside a card with "Try again"
    if (_errorMessage != null) {
      return _buildErrorCard(_errorMessage!);
    }

    // 3. Empty state: short muted text and one OutlineButton
    if (_incidents.isEmpty) {
      return _buildEmptyState();
    }

    // 4. Normal loaded state with reports
    final filtered = _filterIncidents(_incidents);
    final countText =
        '${filtered.length} ${filtered.length == 1 ? 'report' : 'reports'} · Newest first';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Count line
        Text(
          countText,
          style: AppTextStyles.meta,
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        // If filter returned 0 results
        if (filtered.isEmpty) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            'No reports in this category.',
            style: AppTextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),
          OutlineButton(
            label: 'Submit a new report',
            onPressed: widget.onSubmitNew,
          ),
        ] else ...[
          // List of ReportCards (newest first as returned by backend)
          for (int i = 0; i < filtered.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sectionGap),
            ReportCard(
              id: '#${filtered[i].id}',
              date: _formatDate(filtered[i].createdAt),
              category: filtered[i].category,
              location: filtered[i].locationText,
              status: filtered[i].status,
              statusStyle: statusChipStyleFromString(filtered[i].status),
              onTap: null,
            ),
          ],
          const SizedBox(height: AppSpacing.s24),

          // Short muted info text
          Text(
            "Reports can't be edited after you submit them.",
            style: AppTextStyles.meta,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),

          // OutlineButton "Submit a new report"
          OutlineButton(
            label: 'Submit a new report',
            onPressed: widget.onSubmitNew,
          ),
        ],
      ],
    );
  }

  /// Builds 3 skeleton GlassCards for the loading state.
  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sectionGap),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 72,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.cardInnerGap),
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.inner),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Container(
                  width: 96,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.inner),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the error state card with a friendly message and a retry button.
  Widget _buildErrorCard(String message) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTextStyles.body.copyWith(
              color: AppColors.danger,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s12),
          TextButton(
            onPressed: _loadIncidents,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: Text(
              'Try again',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state with short muted text and one action button.
  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.s24),
        Text(
          "You haven't submitted any reports yet.",
          style: AppTextStyles.bodyMuted,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.s16),
        OutlineButton(
          label: 'Submit a new report',
          onPressed: widget.onSubmitNew,
        ),
      ],
    );
  }
}

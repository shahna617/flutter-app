import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/session/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_header.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/glass_card.dart';

/// Student navigation shell holding the fixed bottom navigation bar and tabs.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _currentIndex = 0;

  static const List<AppBottomNavItem> _navItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.add_circle_outline,
      label: 'Submit',
    ),
    AppBottomNavItem(
      icon: Icons.description_outlined,
      label: 'My reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: AppHeader(
        roleName: 'Student',
        onLogout: () => context.read<SessionProvider>().logout(),
      ),
      bottomNavigationBar: AppBottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _StudentHomeTab(),
          _StudentSubmitTab(),
          _StudentMyReportsTab(),
        ],
      ),
    );
  }
}

class _StudentHomeTab extends StatelessWidget {
  const _StudentHomeTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Student home tab placeholder. Real screen content will be placed here by team members.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.s16),
              _TemporaryLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentSubmitTab extends StatelessWidget {
  const _StudentSubmitTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Student report submission form placeholder.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.s16),
              _TemporaryLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _StudentMyReportsTab extends StatelessWidget {
  const _StudentMyReportsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My reports',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Student reports list placeholder.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.s16),
              _TemporaryLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemporaryLogoutButton extends StatelessWidget {
  const _TemporaryLogoutButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => context.read<SessionProvider>().logout(),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.danger,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: AppSpacing.s8,
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 16),
        label: Text(
          'Log out (Temporary)',
          style: AppTextStyles.meta.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

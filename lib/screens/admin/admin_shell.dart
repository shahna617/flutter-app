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

/// Admin navigation shell holding the fixed bottom navigation bar and tabs.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  static const List<AppBottomNavItem> _navItems = [
    AppBottomNavItem(
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    AppBottomNavItem(
      icon: Icons.inbox_outlined,
      label: 'Queue',
    ),
    AppBottomNavItem(
      icon: Icons.notifications_none_outlined,
      label: 'Alerts',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      header: AppHeader(
        roleName: 'Admin',
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
          _AdminHomeTab(),
          _AdminQueueTab(),
          _AdminAlertsTab(),
        ],
      ),
    );
  }
}

class _AdminHomeTab extends StatelessWidget {
  const _AdminHomeTab();

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
                'Admin overview tab placeholder. Real screen content will be placed here by team members.',
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

class _AdminQueueTab extends StatelessWidget {
  const _AdminQueueTab();

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
                'Queue',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Admin report review queue placeholder.',
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

class _AdminAlertsTab extends StatelessWidget {
  const _AdminAlertsTab();

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
                'Alerts',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Admin urgent notifications and alerts placeholder.',
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

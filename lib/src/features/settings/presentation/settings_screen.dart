import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/authentication/presentation/auth_controller.dart';
import '../../../features/homepage/presentation/home_actions.dart';
import '../../../../ui/widgets/common/app_snackbar.dart';
import '../../../../ui/widgets/loaders/app_loading_view.dart';
import '../../../../ui/widgets/modals/app_modal.dart';
import '../../../../ui/widgets/modals/confirmation_modal.dart';
import '../../../../ui/widgets/modals/daily_practice_modal.dart';
import '../../../../ui/widgets/modals/primary_goals_modal.dart';
import '../../../../ui/widgets/modals/dissolve_dialog.dart';
import '../../../../ui/widgets/navigation/app_bottom_nav_bar.dart';
import '../domain/settings_enums.dart';
import '../domain/settings_models.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _editPrimaryGoals(SettingsView settings) async {
    final result = await showModalBottomSheet<List<MainGoals>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) =>
          PrimaryGoalsModal(selectedGoals: settings.primaryGoals.goals),
    );
    if (!mounted || result == null) return;
    final failure = await ref
        .read(settingsControllerProvider.notifier)
        .updatePrimaryGoals(result);
    _showFailureIfNeeded(
      failure,
      fallbackMessage: 'Failed to update primary goals.',
    );
  }

  Future<void> _editDailyPracticeTime(SettingsView settings) async {
    final result = await showModalBottomSheet<DailyPracticeTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => DailyPracticeModal(
        selectedTime: settings.studyAvailability.dailyPracticeTime,
      ),
    );
    if (!mounted || result == null) return;
    final failure = await ref
        .read(settingsControllerProvider.notifier)
        .updateDailyPracticeTime(result);
    _showFailureIfNeeded(
      failure,
      fallbackMessage: 'Failed to update daily practice time.',
    );
  }

  Future<void> _confirmResetAccount() async {
    final confirmed = await showDissolveDialog<bool>(
      context: context,
      builder: (context) => ConfirmationModal(
        description:
            'Resetting your account will clear your learning progress.',
        confirmLabel: 'Reset account',
        confirmColor: const Color(0xFFE08A3D),
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    if (!mounted || confirmed != true) return;
    final failure = await ref
        .read(settingsControllerProvider.notifier)
        .resetAccount();
    _showFailureIfNeeded(
      failure,
      fallbackMessage: 'Failed to reset your account.',
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDissolveDialog<bool>(
      context: context,
      builder: (context) => ConfirmationModal(
        description:
            'Deleting your account permanently removes your data. This action cannot be undone.',
        confirmLabel: 'Delete account',
        confirmColor: const Color(0xFFE03D3D),
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    if (!mounted || confirmed != true) return;
    final failure = await ref
        .read(settingsControllerProvider.notifier)
        .deleteAccount();
    _showFailureIfNeeded(
      failure,
      fallbackMessage: 'Failed to delete your account.',
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDissolveDialog<bool>(
      context: context,
      builder: (context) => AppModal(
        title: 'Log out?',
        description: 'You will need to sign in again to access your account.',
        primaryLabel: 'Log out',
        onPrimary: () => Navigator.pop(context, true),
        secondaryLabel: 'Cancel',
        onSecondary: () => Navigator.pop(context, false),
        icon: Icons.logout,
        iconColor: const Color(0xFF2EA9DE),
      ),
    );
    if (!mounted || confirmed != true) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final failure = await ref
        .read(settingsControllerProvider.notifier)
        .updateNotifications(enabled);
    _showFailureIfNeeded(
      failure,
      fallbackMessage: 'Failed to update notifications.',
    );
  }

  void _showFailureIfNeeded(
    Object? failure, {
    required String fallbackMessage,
  }) {
    if (!mounted || failure == null) return;
    showAppSnackBar(
      context,
      '$fallbackMessage ${formatSnackBarError(failure)}',
    );
  }

  Future<void> _handleNavTap(int index) async {
    switch (index) {
      case 0:
        context.goNamed('home');
        return;
      case 1:
        await startSpeakingFlow(context, ref);
        return;
      case 2:
        context.goNamed('practice_history');
        return;
      case 3:
        context.goNamed('settings');
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final settings = settingsAsync.valueOrNull;

    Widget content;
    if (settings == null && settingsAsync.isLoading) {
      content = const AppLoadingView();
    } else if (settings == null && settingsAsync.hasError) {
      content = _SettingsErrorView(
        error: settingsAsync.error,
        onRetry: () => ref.invalidate(settingsControllerProvider),
      );
    } else {
      content = _SettingsContent(
        settings: settings!,
        onPrimaryGoalsTap: () => _editPrimaryGoals(settings),
        onDailyPracticeTap: () => _editDailyPracticeTime(settings),
        onResetTap: _confirmResetAccount,
        onDeleteTap: _confirmDeleteAccount,
        onLogoutTap: _confirmLogout,
        onNotificationsToggle: settingsAsync.isLoading
            ? null
            : _toggleNotifications,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => context.goNamed('practice_history'),
            icon: const Icon(Icons.history),
            tooltip: 'Practice history',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: content),
          if (settings != null)
            AppBottomNavBar(activeIndex: 3, onTap: _handleNavTap),
          if (settingsAsync.isLoading && settings != null)
            const Positioned.fill(child: AppLoadingView()),
        ],
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final SettingsView settings;
  final VoidCallback onPrimaryGoalsTap;
  final VoidCallback onDailyPracticeTap;
  final Future<void> Function(bool)? onNotificationsToggle;
  final VoidCallback onResetTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onLogoutTap;

  const _SettingsContent({
    required this.settings,
    required this.onPrimaryGoalsTap,
    required this.onDailyPracticeTap,
    required this.onNotificationsToggle,
    required this.onResetTap,
    required this.onDeleteTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final goalsLabel = settings.primaryGoals.goals.isEmpty
        ? 'Select your goals'
        : settings.primaryGoals.goals.map((goal) => goal.label).join(', ');
    final practiceLabel = settings.studyAvailability.dailyPracticeTime == null
        ? 'Choose a time'
        : settings.studyAvailability.dailyPracticeTime!.label;
    final notificationsEnabled = settings.notifications.preference.enabled;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
      children: [
        const _SectionTitle(title: 'Profile'),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.flag_outlined,
          title: 'Primary Goals',
          subtitle: goalsLabel,
          onTap: onPrimaryGoalsTap,
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.access_time,
          title: 'Daily Practice Time',
          subtitle: practiceLabel,
          onTap: onDailyPracticeTap,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Notifications'),
        const SizedBox(height: 12),
        _SettingsToggleTile(
          icon: Icons.notifications_active_outlined,
          title: 'Notifications',
          subtitle: notificationsEnabled ? 'Enabled' : 'Disabled',
          value: notificationsEnabled,
          onChanged: onNotificationsToggle == null
              ? null
              : (value) => onNotificationsToggle!(value),
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Account'),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.logout,
          title: 'Log out',
          subtitle: 'Sign out of YamFluent on this device.',
          onTap: onLogoutTap,
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.refresh,
          title: 'Reset Account',
          subtitle: 'Clear your progress and start fresh.',
          titleColor: const Color(0xAF000000),
          onTap: onResetTap,
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.delete_outline,
          title: 'Delete Account',
          subtitle: 'Permanently remove your data.',
          titleColor: const Color(0xAF000000),
          onTap: onDeleteTap,
        ),
      ],
    );
  }
}

class _SettingsErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _SettingsErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unable to load settings.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error?.toString() ?? 'Something went wrong.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: const Color(0xFF7A8B94),
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F6F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF3D4C52)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? const Color(0xAF000000),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF66757D),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9AA7AE)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F6F8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF3D4C52)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C1A1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF66757D),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: const Color(0xFFFFFFFF),
              activeTrackColor: const Color(0xFF2EA9DE),
              trackOutlineColor: const WidgetStatePropertyAll(
                Color(0x00000000),
              ),
              inactiveTrackColor: const Color(0xFFECECEC),
            ),
          ],
        ),
      ),
    );
  }
}

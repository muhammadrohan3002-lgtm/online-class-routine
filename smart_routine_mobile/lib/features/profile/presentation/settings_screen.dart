import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/core_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late double _threshold;
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    final storage = ref.read(storageServiceProvider);
    _threshold = storage.getAttendanceThreshold().toDouble();
    _notificationsEnabled = storage.getNotificationsEnabled();
  }

  Future<void> _updateThreshold(double value) async {
    setState(() => _threshold = value);
    final storage = ref.read(storageServiceProvider);
    await storage.setAttendanceThreshold(value.round());
    // Also sync with backend profile
    ref.read(authProvider.notifier).updateProfile(attendanceThreshold: value.round());
  }

  Future<void> _updateNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final storage = ref.read(storageServiceProvider);
    await storage.setNotificationsEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Theme & Appearance'),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Light Mode'),
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark Mode'),
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) => ref.read(themeProvider.notifier).setThemeMode(mode!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Attendance Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Warning Threshold',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_threshold.round()}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You will receive warnings when attendance drops below this minimum percentage.',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _threshold,
                      min: 50,
                      max: 95,
                      divisions: 9,
                      label: '${_threshold.round()}%',
                      activeColor: AppColors.primary,
                      onChanged: _updateThreshold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Notifications'),
            Card(
              child: SwitchListTile(
                secondary: const Icon(Icons.notifications_active_outlined),
                title: const Text('Class & Exam Alerts'),
                subtitle: const Text('Receive push alerts before classes and upcoming exams', style: TextStyle(fontSize: 11)),
                value: _notificationsEnabled,
                onChanged: _updateNotifications,
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Backend Connection'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings_ethernet_rounded),
                title: const Text('REST API Server URL'),
                subtitle: const Text('Switch between emulator, LAN, and remote URLs', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/settings/server'),
              ),
            ),
            const SizedBox(height: 24),

            // Sign out tile
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
              ),
              tileColor: AppColors.errorContainer.withOpacity(0.3),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.errorText, fontWeight: FontWeight.bold)),
              onTap: () {
                ref.read(authProvider.notifier).logout();
                context.go('/welcome');
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).hintColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

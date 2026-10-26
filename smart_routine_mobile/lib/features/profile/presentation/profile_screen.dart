import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = authState.user;

    final initial = user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Student Identity Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'CSE Student',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  if (user?.studentId.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ID: ${user!.studentId}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  if (user != null && (user.email == 'guest@cse.edu' || user.id.contains('guest'))) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_rounded, size: 14, color: AppColors.secondary),
                          SizedBox(width: 6),
                          Text(
                            'Guest / Evaluator Mode',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (user?.department.isNotEmpty == true || user?.institution.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (user?.department.isNotEmpty == true)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            user!.department,
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    if (user?.institution.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            user!.institution,
                            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Links
            _buildSectionHeader(context, 'Academic Shortcuts'),
            _buildSettingsTile(
              context,
              icon: Icons.bookmark_outline_rounded,
              color: AppColors.primary,
              title: 'My Courses',
              subtitle: 'Manage semester course catalog and credits',
              onTap: () => context.push('/courses'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.how_to_reg_rounded,
              color: AppColors.success,
              title: 'Attendance Tracker',
              subtitle: 'View percentages and session logs',
              onTap: () => context.push('/attendance'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.timer_outlined,
              color: AppColors.secondary,
              title: 'Study Planner & Focus Timer',
              subtitle: 'Track daily goals and weekly study hours',
              onTap: () => context.push('/study-planner'),
            ),
            const SizedBox(height: 16),

            _buildSectionHeader(context, 'Preferences & Settings'),
            _buildSettingsTile(
              context,
              icon: Icons.person_outline_rounded,
              color: const Color(0xFF0891B2),
              title: 'Edit Profile',
              subtitle: 'Update name, ID, and university information',
              onTap: () => context.push('/profile/edit'),
            ),
            _buildSettingsTile(
              context,
              icon: themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: const Color(0xFFD97706),
              title: 'Theme Mode',
              subtitle: themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
              trailing: Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
              onTap: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.settings_ethernet_rounded,
              color: const Color(0xFF7C3AED),
              title: 'Server Connection',
              subtitle: 'Configure backend REST API endpoint',
              onTap: () => context.push('/settings/server'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.tune_rounded,
              color: const Color(0xFF475569),
              title: 'All App Settings',
              subtitle: 'Notifications, attendance thresholds, and more',
              onTap: () => context.push('/settings'),
            ),
            const SizedBox(height: 16),

            // Sign Out Button
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.error.withOpacity(0.3)),
              ),
              tileColor: AppColors.errorContainer.withOpacity(0.3),
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.errorText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _confirmSignOut(context, ref),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).hintColor,
            ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of Smart Routine?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

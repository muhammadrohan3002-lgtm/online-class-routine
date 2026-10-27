import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/stat_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/dashboard_attendance_card.dart';
import 'widgets/next_class_card.dart';
import 'widgets/quick_actions_grid.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardState = ref.watch(dashboardProvider);

    final user = authState.user;
    final data = dashboardState.data;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data?.greeting ?? 'Hello, ${user?.name.split(' ').first ?? 'Student'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              DateTimeUtils.formatReadableDate(data?.todayDate ?? DateTimeUtils.toIsoDateString(DateTime.now())),
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Focus Study Timer',
            onPressed: () => context.push('/study-planner/timer'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications are active for classes and exams.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).fetchDashboard();
        },
        child: dashboardState.isLoading && data == null
            ? const LoadingIndicator(message: 'Loading your student dashboard...')
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (dashboardState.error != null)
                      ErrorBanner(
                        message: dashboardState.error!,
                        onRetry: () => ref.read(dashboardProvider.notifier).fetchDashboard(),
                      ),

                    if (user != null && (user.email == 'guest@cse.edu' || user.id.contains('guest')))
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.explore_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Guest Mode active: exploring sample CSE routine & tasks.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => context.push('/register'),
                              child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                    // Quick Summary Stat Cards
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: "Today's Classes",
                            value: '${data?.todayClassesCount ?? 0}',
                            icon: Icons.calendar_today_rounded,
                            iconColor: AppColors.primary,
                            backgroundColor: AppColors.primaryContainer,
                            onTap: () => context.go('/routine'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Pending Tasks',
                            value: '${data?.pendingTasksCount ?? 0}',
                            icon: Icons.check_box_outlined,
                            iconColor: AppColors.warning,
                            backgroundColor: AppColors.warningContainer,
                            onTap: () => context.go('/tasks'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Next Class or Finished State
                    if (data?.nextClass != null) ...[
                      NextClassCard(
                        nextClass: data!.nextClass!,
                        onTap: () => context.go('/routine'),
                      ),
                      const SizedBox(height: 18),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.done_all_rounded, color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'No More Classes Today',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    'All done for today! Review pending tasks or study ahead.',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Quick Actions
                    QuickActionsGrid(
                      actions: [
                        QuickActionItem(
                          title: 'Add Class',
                          icon: Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          onTap: () {
                            if (checkGuestRestricted(context, ref, action: 'add class schedules')) return;
                            context.push('/routine/add');
                          },
                        ),
                        QuickActionItem(
                          title: 'New Task',
                          icon: Icons.add_task_rounded,
                          color: AppColors.warning,
                          onTap: () {
                            if (checkGuestRestricted(context, ref, action: 'create new tasks')) return;
                            context.push('/tasks/add');
                          },
                        ),
                        QuickActionItem(
                          title: 'Attendance',
                          icon: Icons.how_to_reg_rounded,
                          color: AppColors.success,
                          onTap: () => context.push('/attendance'),
                        ),
                        QuickActionItem(
                          title: 'Study Timer',
                          icon: Icons.timer_outlined,
                          color: AppColors.secondary,
                          onTap: () => context.push('/study-planner/timer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Attendance Overview Card
                    if (data?.attendanceOverview != null) ...[
                      DashboardAttendanceCard(
                        overview: data!.attendanceOverview,
                        onTap: () => context.push('/attendance'),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Upcoming Exams & Deadlines Preview
                    if (data?.upcomingExams != null && data!.upcomingExams.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Upcoming Exams & Quizzes',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/calendar'),
                            child: const Text('View All', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...data.upcomingExams.map((exam) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.event_note_rounded, color: AppColors.secondary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.subject,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      '${exam.type.toUpperCase()} • ${DateTimeUtils.formatReadableDate(exam.date)} at ${DateTimeUtils.formatTimeTo12Hour(exam.time)}',
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: exam.daysRemaining <= 1
                                      ? AppColors.errorContainer
                                      : AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  exam.daysRemaining == 0
                                      ? 'TODAY'
                                      : exam.daysRemaining == 1
                                          ? 'TOMORROW'
                                          : 'In ${exam.daysRemaining}d',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: exam.daysRemaining <= 1
                                        ? AppColors.errorText
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

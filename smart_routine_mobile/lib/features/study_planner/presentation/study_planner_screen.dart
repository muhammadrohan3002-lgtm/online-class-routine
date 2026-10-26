import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/study_session_provider.dart';
import 'widgets/weekly_study_chart.dart';

class StudyPlannerScreen extends ConsumerWidget {
  const StudyPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plannerState = ref.watch(studyPlannerProvider);
    final notifier = ref.read(studyPlannerProvider.notifier);
    final progress = plannerState.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Launch Focus Timer',
            onPressed: () => context.push('/study-planner/timer'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchData(),
        child: plannerState.isLoading && plannerState.sessions.isEmpty
            ? const LoadingIndicator(message: 'Loading study sessions...')
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (plannerState.error != null)
                      ErrorBanner(
                        message: plannerState.error!,
                        onRetry: () => notifier.fetchData(),
                      ),

                    // Weekly Overview Card
                    if (progress != null) ...[
                      WeeklyStudyChart(days: progress.weeklyBreakdown),
                      const SizedBox(height: 16),

                      // Quick Stats Row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatColumn(
                              context,
                              '${(progress.totalCompletedMinutes / 60).toStringAsFixed(1)} hrs',
                              'Time Studied',
                              AppColors.primary,
                            ),
                            Container(width: 1, height: 36, color: Theme.of(context).dividerColor),
                            _buildStatColumn(
                              context,
                              '${(progress.totalTargetMinutes / 60).toStringAsFixed(1)} hrs',
                              'Target Goal',
                              Colors.grey,
                            ),
                            Container(width: 1, height: 36, color: Theme.of(context).dividerColor),
                            _buildStatColumn(
                              context,
                              '${progress.overallProgressPercentage}%',
                              'Goal Achieved',
                              AppColors.success,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Focus Timer Promotion Card
                    InkWell(
                      onTap: () => context.push('/study-planner/timer'),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Launch Focus Study Timer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pomodoro focus sessions directly track your study hours',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logged Sessions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Study History & Logs',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Log Manually', style: TextStyle(fontSize: 12)),
                          onPressed: () => _showAddSessionDialog(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sessions List
                    if (plannerState.sessions.isEmpty)
                      const EmptyStateView(
                        icon: Icons.history_edu_rounded,
                        title: 'No Study Sessions Logged',
                        subtitle: 'Use the Focus Timer or log a session manually to track your study habits.',
                      )
                    else
                      ...plannerState.sessions.map((session) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    session.courseName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${session.completedMinutes} / ${session.targetMinutes} mins',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateTimeUtils.formatReadableDate(session.date),
                                style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                              ),
                              if (session.notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  session.notes,
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (session.progressPercentage / 100),
                                        minHeight: 5,
                                        backgroundColor: AppColors.primaryContainer.withOpacity(0.5),
                                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                    tooltip: 'Delete Log',
                                    onPressed: () => notifier.deleteSession(session.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'study_planner_fab',
        icon: const Icon(Icons.timer_outlined),
        label: const Text('Focus Timer'),
        onPressed: () => context.push('/study-planner/timer'),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  void _showAddSessionDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final notesController = TextEditingController();
    final targetController = TextEditingController(text: '60');
    final completedController = TextEditingController(text: '45');
    String? selectedCourseId;
    String selectedCourseName = 'General CSE Study';

    final courses = ref.read(courseProvider).courses;
    if (courses.isNotEmpty) {
      selectedCourseId = courses.first.id;
      selectedCourseName = courses.first.name;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Log Study Session'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (courses.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: selectedCourseId,
                        decoration: const InputDecoration(labelText: 'Course'),
                        items: [
                          const DropdownMenuItem(value: null, child: Text('General CSE Study')),
                          ...courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.code))),
                        ],
                        onChanged: (val) {
                          final c = courses.where((e) => e.id == val).firstOrNull;
                          setState(() {
                            selectedCourseId = val;
                            selectedCourseName = c?.name ?? 'General CSE Study';
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: completedController,
                      decoration: const InputDecoration(labelText: 'Completed Minutes *'),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: targetController,
                      decoration: const InputDecoration(labelText: 'Target Minutes'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes / Topic studied'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  Navigator.pop(ctx);
                  await ref.read(studyPlannerProvider.notifier).createSession(
                        courseId: selectedCourseId,
                        courseName: selectedCourseName,
                        date: DateTimeUtils.toIsoDateString(DateTime.now()),
                        targetMinutes: int.tryParse(targetController.text) ?? 60,
                        completedMinutes: int.tryParse(completedController.text) ?? 45,
                        notes: notesController.text.trim(),
                      );
                },
                child: const Text('Save Log'),
              ),
            ],
          );
        },
      ),
    );
  }
}

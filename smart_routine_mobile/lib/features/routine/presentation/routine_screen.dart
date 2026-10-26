import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../courses/providers/course_provider.dart';
import '../providers/routine_provider.dart';
import 'widgets/day_selector_strip.dart';
import 'widgets/routine_card.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);
    final courseState = ref.watch(courseProvider);
    final notifier = ref.read(routineProvider.notifier);

    // Compute class count per day for badges
    final countsPerDay = <int, int>{};
    for (final r in routineState.routines) {
      countsPerDay[r.dayOfWeek] = (countsPerDay[r.dayOfWeek] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Routine'),
        actions: [
          // Manage Courses shortcut
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'Manage Courses',
            onPressed: () => context.push('/courses'),
          ),
          // View Mode Toggle (Daily vs Full Weekly)
          IconButton(
            icon: Icon(
              routineState.isWeeklyView
                  ? Icons.calendar_view_day_rounded
                  : Icons.calendar_view_week_rounded,
            ),
            tooltip: routineState.isWeeklyView ? 'Switch to Daily View' : 'Switch to Full Week View',
            onPressed: () => notifier.toggleViewMode(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchRoutines(),
        child: Column(
          children: [
            if (routineState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(
                  message: routineState.error!,
                  onRetry: () => notifier.fetchRoutines(),
                ),
              ),

            // Course Filter dropdown (if user has courses)
            if (courseState.courses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Course: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Expanded(
                      child: DropdownButton<String?>(
                        value: routineState.filterCourseId,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        hint: const Text('All Courses', style: TextStyle(fontSize: 12)),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Courses', style: TextStyle(fontSize: 12)),
                          ),
                          ...courseState.courses.map((c) {
                            return DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 12)),
                            );
                          }),
                        ],
                        onChanged: (val) => notifier.setCourseFilter(val),
                      ),
                    ),
                  ],
                ),
              ),

            // Saturday-Friday Day Selector Strip (Daily View only)
            if (!routineState.isWeeklyView) ...[
              const SizedBox(height: 6),
              DaySelectorStrip(
                selectedDay: routineState.selectedDay,
                onDaySelected: (day) => notifier.selectDay(day),
                classCountsPerDay: countsPerDay,
              ),
              const SizedBox(height: 10),
            ],

            // Routine List
            Expanded(
              child: routineState.isLoading && routineState.routines.isEmpty
                  ? const LoadingIndicator(message: 'Loading timetable...')
                  : routineState.isWeeklyView
                      ? _buildWeeklyView(context, ref)
                      : _buildDailyView(context, ref),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'routine_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        onPressed: () => context.push('/routine/add?day=${routineState.selectedDay}'),
      ),
    );
  }

  Widget _buildDailyView(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);
    final filtered = routineState.filteredRoutines;
    final dayName = DateTimeUtils.getDayName(routineState.selectedDay);

    if (filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.event_available_rounded,
        title: 'No Classes Scheduled',
        subtitle: 'There are no classes scheduled for $dayName.',
        buttonText: 'Add Class for $dayName',
        onButtonPressed: () => context.push('/routine/add?day=${routineState.selectedDay}'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final routine = filtered[index];
        return RoutineCard(
          routine: routine,
          onEdit: () => context.push('/routine/edit/${routine.id}'),
          onDelete: () => _confirmDelete(context, ref, routine.id, routine.courseCode),
          onRecordAttendance: () {
            context.push(
              '/attendance?record=true&courseId=${routine.courseId}&courseName=${Uri.encodeComponent(routine.courseName)}',
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyView(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);
    final weeklyMap = routineState.weeklyGroupedRoutines;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 7,
      itemBuilder: (context, dayIndex) {
        final dayName = AppStrings.daysOfWeek[dayIndex];
        final dayClasses = weeklyMap[dayIndex] ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  Text(
                    '${dayClasses.length} ${dayClasses.length == 1 ? 'class' : 'classes'}',
                    style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (dayClasses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'No classes scheduled',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    ),
                  ),
                )
              else
                ...dayClasses.map((routine) {
                  return RoutineCard(
                    routine: routine,
                    onEdit: () => context.push('/routine/edit/${routine.id}'),
                    onDelete: () => _confirmDelete(context, ref, routine.id, routine.courseCode),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String courseCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class Schedule'),
        content: Text('Are you sure you want to remove $courseCode from your routine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(routineProvider.notifier).deleteRoutine(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

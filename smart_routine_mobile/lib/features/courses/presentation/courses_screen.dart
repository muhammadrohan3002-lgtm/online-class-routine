import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/guest_mode_banner.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/course_provider.dart';

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseState = ref.watch(courseProvider);
    final notifier = ref.read(courseProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchCourses(),
        child: courseState.isLoading && courseState.courses.isEmpty
            ? const LoadingIndicator(message: 'Loading courses...')
            : Column(
                children: [
                  const GuestModeBanner(),
                  if (courseState.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorBanner(
                        message: courseState.error!,
                        onRetry: () => notifier.fetchCourses(),
                      ),
                    ),
                  Expanded(
                    child: courseState.courses.isEmpty
                        ? EmptyStateView(
                            icon: Icons.school_outlined,
                            title: 'No Courses Added Yet',
                            subtitle: 'Add your semester courses to link routines, exams, and attendance.',
                            buttonText: 'Add First Course',
                            onButtonPressed: () {
                              if (checkGuestRestricted(context, ref, action: 'add semester courses')) return;
                              context.push('/courses/add');
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                            itemCount: courseState.courses.length,
                            itemBuilder: (context, index) {
                              final course = courseState.courses[index];
                              final color = AppColors.hexToColor(course.colorHex);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(width: 6, color: color),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      course.code,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: color,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: color.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        '${course.credits} Credits',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: color,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  course.name,
                                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                if (course.teacher.isNotEmpty || course.room.isNotEmpty) ...[
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      if (course.teacher.isNotEmpty) ...[
                                                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          course.teacher,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 12),
                                                      ],
                                                      if (course.room.isNotEmpty) ...[
                                                        const Icon(Icons.meeting_room_outlined, size: 14, color: Colors.grey),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          course.room,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Theme.of(context).hintColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                                const SizedBox(height: 12),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                                      tooltip: 'Edit Course',
                                                      onPressed: () {
                                                        if (checkGuestRestricted(context, ref, action: 'edit courses')) return;
                                                        context.push('/courses/edit/${course.id}');
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                                      tooltip: 'Delete Course',
                                                      onPressed: () {
                                                        if (checkGuestRestricted(context, ref, action: 'delete courses')) return;
                                                        _confirmDelete(context, ref, course.id, course.name);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'courses_fab',
        icon: const Icon(Icons.add),
        label: const Text('New Course'),
        onPressed: () {
          if (checkGuestRestricted(context, ref, action: 'add semester courses')) return;
          context.push('/courses/add');
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String courseName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "$courseName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(courseProvider.notifier).deleteCourse(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

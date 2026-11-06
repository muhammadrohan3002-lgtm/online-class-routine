import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/guest_mode_banner.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/exam_provider.dart';
import 'widgets/exam_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examState = ref.watch(examProvider);
    final notifier = ref.read(examProvider.notifier);
    final notificationService = ref.read(notificationServiceProvider);

    final filtered = examState.filteredExams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams & Assessments'),
        actions: [
          Row(
            children: [
              Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: examState.showUpcomingOnly ? AppColors.primary : Theme.of(context).hintColor,
                ),
              ),
              Switch(
                value: examState.showUpcomingOnly,
                onChanged: (_) => notifier.toggleUpcomingOnly(),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchExams(),
        child: Column(
          children: [
            const GuestModeBanner(),
            if (examState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ErrorBanner(
                  message: examState.error!,
                  onRetry: () => notifier.fetchExams(),
                ),
              ),

            // Exam Type Filter Strip
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Events'),
                    selected: examState.selectedType == 'all',
                    onSelected: (_) => notifier.setTypeFilter('all'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: examState.selectedType == 'all' ? Colors.white : null,
                      fontWeight: examState.selectedType == 'all' ? FontWeight.bold : null,
                      fontSize: 12,
                    ),
                  ),
                  ...AppStrings.examTypes.map((type) {
                    final isSelected = examState.selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(type.toUpperCase()),
                        selected: isSelected,
                        onSelected: (_) => notifier.setTypeFilter(type),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Exam Cards List
            Expanded(
              child: examState.isLoading && examState.exams.isEmpty
                  ? const LoadingIndicator(message: 'Loading exams...')
                  : filtered.isEmpty
                      ? EmptyStateView(
                          icon: Icons.event_available_rounded,
                          title: 'No Exams Scheduled',
                          subtitle: 'Stay ahead of your semester by adding your midterms, finals, and quizzes.',
                          buttonText: 'Add First Exam',
                          onButtonPressed: () {
                            if (checkGuestRestricted(context, ref, action: 'schedule exams and assessments')) return;
                            context.push('/calendar/add');
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final exam = filtered[index];
                            return ExamCard(
                              exam: exam,
                              onEdit: () {
                                if (checkGuestRestricted(context, ref, action: 'edit exams')) return;
                                context.push('/calendar/edit/${exam.id}');
                              },
                              onDelete: () {
                                if (checkGuestRestricted(context, ref, action: 'delete exams')) return;
                                _confirmDelete(context, ref, exam.id, exam.subject);
                              },
                              onSetReminder: () async {
                                await notificationService.showNotification(
                                  id: exam.id.hashCode,
                                  title: 'Reminder: ${exam.subject} (${exam.typeLabel})',
                                  body: 'Scheduled on ${exam.date} at ${exam.time} in ${exam.location}',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Reminder set for ${exam.subject}'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar_fab',
        icon: const Icon(Icons.add),
        label: const Text('Add Exam'),
        onPressed: () {
          if (checkGuestRestricted(context, ref, action: 'schedule exams and assessments')) return;
          context.push('/calendar/add');
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String subject) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Exam / Assessment'),
        content: Text('Are you sure you want to remove "$subject"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(examProvider.notifier).deleteExam(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

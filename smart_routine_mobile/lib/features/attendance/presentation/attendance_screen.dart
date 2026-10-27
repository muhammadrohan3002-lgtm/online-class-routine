import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/guest_mode_banner.dart';
import '../../../core/widgets/guest_restriction_dialog.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/attendance_provider.dart';
import 'record_attendance_dialog.dart';
import 'widgets/attendance_course_card.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  final bool autoOpenRecord;
  final String? initialCourseId;
  final String? initialCourseName;

  const AttendanceScreen({
    super.key,
    this.autoOpenRecord = false,
    this.initialCourseId,
    this.initialCourseName,
  });

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.autoOpenRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRecordDialog(
          courseId: widget.initialCourseId,
          courseName: widget.initialCourseName,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRecordDialog({String? courseId, String? courseName}) {
    if (checkGuestRestricted(context, ref, action: 'record attendance')) return;
    showDialog(
      context: context,
      builder: (ctx) => RecordAttendanceDialog(
        initialCourseId: courseId,
        initialCourseName: courseName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final notifier = ref.read(attendanceProvider.notifier);
    final summary = attendanceState.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Change Warning Threshold',
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(context).hintColor,
          tabs: const [
            Tab(text: 'Course Summaries'),
            Tab(text: 'History Log'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.fetchData(),
        child: attendanceState.isLoading && summary == null
            ? const LoadingIndicator(message: 'Calculating attendance...')
            : Column(
                children: [
                  const GuestModeBanner(),
                  if (attendanceState.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ErrorBanner(
                        message: attendanceState.error!,
                        onRetry: () => notifier.fetchData(),
                      ),
                    ),

                  // Overall Stats Banner
                  if (summary != null)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: summary.isBelowThreshold
                              ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                              : [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (summary.isBelowThreshold ? AppColors.error : AppColors.primary)
                                .withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Overall Attendance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${summary.percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  summary.isBelowThreshold
                                      ? '⚠️ Below ${summary.threshold}%'
                                      : '✓ Above ${summary.threshold}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildWhiteStat('Present', '${summary.present}'),
                              _buildWhiteStat('Late', '${summary.late}'),
                              _buildWhiteStat('Absent', '${summary.absent}'),
                              _buildWhiteStat('Total', '${summary.totalClasses}'),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Course Summaries
                        _buildSummariesTab(context, summary),
                        // Tab 2: Attendance History
                        _buildHistoryTab(context, attendanceState, notifier),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'attendance_fab',
        icon: const Icon(Icons.add),
        label: const Text('Record Attendance'),
        onPressed: () => _showRecordDialog(),
      ),
    );
  }

  Widget _buildSummariesTab(BuildContext context, summary) {
    if (summary == null || summary.courses.isEmpty) {
      return EmptyStateView(
        icon: Icons.how_to_reg_rounded,
        title: 'No Course Attendance Data',
        subtitle: 'Record attendance for your classes to view course-by-course analytics.',
        buttonText: 'Record First Session',
        onButtonPressed: () => _showRecordDialog(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: summary.courses.length,
      itemBuilder: (context, index) {
        final courseSummary = summary.courses[index];
        return AttendanceCourseCard(
          summary: courseSummary,
          threshold: summary.threshold,
          onRecordAttendance: () => _showRecordDialog(
            courseId: courseSummary.courseId,
            courseName: courseSummary.courseName,
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    attendanceState,
    AttendanceNotifier notifier,
  ) {
    final history = attendanceState.history;

    if (history.isEmpty) {
      return const EmptyStateView(
        icon: Icons.history_rounded,
        title: 'No Attendance Records',
        subtitle: 'Recorded sessions will appear here chronologically.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
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
              StatusBadge.attendance(item.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.courseName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      DateTimeUtils.formatReadableDate(item.date),
                      style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.notes,
                        style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                tooltip: 'Delete Log',
                onPressed: () {
                  if (checkGuestRestricted(context, ref, action: 'delete attendance logs')) return;
                  notifier.deleteRecord(item.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWhiteStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

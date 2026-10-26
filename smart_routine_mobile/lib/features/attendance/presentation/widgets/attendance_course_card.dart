import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/attendance_model.dart';

class AttendanceCourseCard extends StatelessWidget {
  final CourseAttendanceSummary summary;
  final int threshold;
  final VoidCallback onRecordAttendance;

  const AttendanceCourseCard({
    super.key,
    required this.summary,
    required this.threshold,
    required this.onRecordAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.hexToColor(summary.colorHex);
    final isLow = summary.isBelowThreshold && summary.total > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLow
              ? AppColors.error.withOpacity(0.4)
              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.courseCode.isNotEmpty ? summary.courseCode : 'COURSE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summary.courseName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLow ? AppColors.errorContainer : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isLow ? AppColors.errorText : AppColors.successText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (summary.percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isLow ? AppColors.errorContainer : AppColors.successContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLow ? AppColors.error : AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Count Breakdown (Present, Late, Absent, Total)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Present', '${summary.present}', AppColors.success),
                _buildStatItem('Late', '${summary.late}', AppColors.warning),
                _buildStatItem('Absent', '${summary.absent}', AppColors.error),
                _buildStatItem('Total Held', '${summary.total}', Colors.grey),
              ],
            ),

            if (isLow) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.errorText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Below minimum required threshold ($threshold%). You need to attend upcoming sessions.',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Record Attendance', style: TextStyle(fontSize: 12)),
                onPressed: onRecordAttendance,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/dashboard_model.dart';

class DashboardAttendanceCard extends StatelessWidget {
  final AttendanceOverviewModel overview;
  final VoidCallback? onTap;

  const DashboardAttendanceCard({
    super.key,
    required this.overview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = overview.isBelowThreshold;
    final percentage = overview.percentage;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning
                ? AppColors.error.withOpacity(0.4)
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isWarning
                            ? AppColors.errorContainer
                            : AppColors.successContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isWarning
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        color: isWarning ? AppColors.error : AppColors.success,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Attendance',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Threshold: ${overview.threshold}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: isWarning
                    ? AppColors.errorContainer
                    : AppColors.successContainer,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isWarning ? AppColors.error : AppColors.success,
                ),
              ),
            ),
            if (isWarning) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.errorText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Attention: Attendance is below your ${overview.threshold}% minimum threshold!',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.errorText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

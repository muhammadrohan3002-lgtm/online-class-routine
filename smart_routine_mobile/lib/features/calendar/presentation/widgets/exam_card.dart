import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../models/exam_model.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetReminder;

  const ExamCard({
    super.key,
    required this.exam,
    required this.onEdit,
    required this.onDelete,
    this.onSetReminder,
  });

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'midterm':
        return const Color(0xFFD97706); // Amber
      case 'final':
        return const Color(0xFFDC2626); // Red
      case 'quiz':
        return AppColors.primary; // Blue
      case 'lab':
        return const Color(0xFF059669); // Emerald
      case 'presentation':
        return AppColors.secondary; // Indigo
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(exam.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: exam.daysRemaining == 0
              ? AppColors.error.withOpacity(0.5)
              : Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: typeColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exam.typeLabel.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                          // Countdown Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: exam.isPast
                                  ? Colors.grey.withOpacity(0.2)
                                  : exam.daysRemaining <= 1
                                      ? AppColors.errorContainer
                                      : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exam.isPast
                                  ? 'COMPLETED'
                                  : exam.daysRemaining == 0
                                      ? 'TODAY'
                                      : exam.daysRemaining == 1
                                          ? 'TOMORROW'
                                          : 'In ${exam.daysRemaining} days',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: exam.isPast
                                    ? Colors.grey
                                    : exam.daysRemaining <= 1
                                        ? AppColors.errorText
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exam.subject,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (exam.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          exam.notes,
                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Date & Time
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.event_outlined, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  DateTimeUtils.formatReadableDate(exam.date),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 3),
                                Text(
                                  DateTimeUtils.formatTimeTo12Hour(exam.time),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (exam.location.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              exam.location,
                              style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onSetReminder != null && !exam.isPast)
                            TextButton.icon(
                              icon: const Icon(Icons.notifications_active_outlined, size: 16),
                              label: const Text('Remind Me', style: TextStyle(fontSize: 11)),
                              onPressed: onSetReminder,
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit Exam',
                            onPressed: onEdit,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                            tooltip: 'Delete Exam',
                            onPressed: onDelete,
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
  }
}

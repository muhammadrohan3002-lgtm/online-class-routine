import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../models/routine_model.dart';

class RoutineCard extends StatelessWidget {
  final RoutineModel routine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onRecordAttendance;

  const RoutineCard({
    super.key,
    required this.routine,
    this.onEdit,
    this.onDelete,
    this.onRecordAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.hexToColor(routine.colorHex);
    final durationMins = DateTimeUtils.timeToMinutes(routine.endTime) -
        DateTimeUtils.timeToMinutes(routine.startTime);

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
              // Left color indicator bar
              Container(
                width: 6,
                color: color,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      routine.courseCode,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${durationMins > 0 ? durationMins : 90} mins',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  routine.courseName,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Actions Popup Menu
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'edit') onEdit?.call();
                              if (val == 'delete') onDelete?.call();
                              if (val == 'attendance') onRecordAttendance?.call();
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'attendance',
                                child: Row(
                                  children: [
                                    Icon(Icons.how_to_reg_rounded, size: 18, color: AppColors.success),
                                    SizedBox(width: 8),
                                    Text('Record Attendance'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit Class'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                    SizedBox(width: 8),
                                    Text('Delete Class', style: TextStyle(color: AppColors.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Time
                          const Icon(Icons.schedule_rounded, size: 15, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            '${DateTimeUtils.formatTimeTo12Hour(routine.startTime)} - ${DateTimeUtils.formatTimeTo12Hour(routine.endTime)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 14),
                          // Room
                          const Icon(Icons.meeting_room_outlined, size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            routine.room.isNotEmpty ? routine.room : 'TBA',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      if (routine.teacher.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, size: 15, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              routine.teacher,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).hintColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                      if (routine.conflictWarning != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warningText),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  routine.conflictWarning!,
                                  style: const TextStyle(fontSize: 10, color: AppColors.warningText),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

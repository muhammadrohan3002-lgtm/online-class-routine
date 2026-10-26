import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../models/dashboard_model.dart';

class NextClassCard extends StatelessWidget {
  final NextClassModel nextClass;
  final VoidCallback? onTap;

  const NextClassCard({
    super.key,
    required this.nextClass,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final courseColor = AppColors.hexToColor(nextClass.colorHex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: nextClass.isOngoing
                ? AppColors.success.withOpacity(0.5)
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            width: nextClass.isOngoing ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: courseColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: courseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      nextClass.isOngoing ? 'ONGOING CLASS' : 'NEXT UPCOMING CLASS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: nextClass.isOngoing ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (nextClass.isOngoing)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, size: 8, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Active Now',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.successText,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              nextClass.courseCode,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: courseColor,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              nextClass.courseName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                // Time
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${DateTimeUtils.formatTimeTo12Hour(nextClass.startTime)} - ${DateTimeUtils.formatTimeTo12Hour(nextClass.endTime)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Room
                Row(
                  children: [
                    const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      nextClass.room.isNotEmpty ? nextClass.room : 'TBA',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

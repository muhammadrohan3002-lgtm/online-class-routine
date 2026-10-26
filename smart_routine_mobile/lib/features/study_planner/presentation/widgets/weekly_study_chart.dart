import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/study_session_model.dart';

class WeeklyStudyChart extends StatelessWidget {
  final List<WeeklyStudyDayModel> days;

  const WeeklyStudyChart({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    // Find max minutes to scale chart height
    int maxMins = 120;
    for (final d in days) {
      if (d.completedMinutes > maxMins) maxMins = d.completedMinutes;
      if (d.targetMinutes > maxMins) maxMins = d.targetMinutes;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Study Activity',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildLegend(AppColors.primary, 'Completed'),
                  const SizedBox(width: 12),
                  _buildLegend(Colors.grey.shade400, 'Target'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((day) {
                final completedHeight = maxMins > 0 ? (day.completedMinutes / maxMins) * 100 : 0.0;
                final targetHeight = maxMins > 0 ? (day.targetMinutes / maxMins) * 100 : 0.0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${day.completedMinutes}m',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: day.completedMinutes > 0 ? AppColors.primary : Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 100,
                      width: 24,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Target outline / background bar
                          Container(
                            height: targetHeight.clamp(4.0, 100.0),
                            width: 18,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          // Completed solid bar
                          Container(
                            height: completedHeight.clamp(0.0, 100.0),
                            width: 18,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      day.day,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

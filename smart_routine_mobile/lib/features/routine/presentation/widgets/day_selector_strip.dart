import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class DaySelectorStrip extends StatelessWidget {
  final int selectedDay; // 0..6 (Sat..Fri)
  final void Function(int) onDaySelected;
  final Map<int, int>? classCountsPerDay;

  const DaySelectorStrip({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.classCountsPerDay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: AppStrings.daysOfWeekShort.length,
        itemBuilder: (context, index) {
          final isSelected = selectedDay == index;
          final count = classCountsPerDay?[index] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              showCheckmark: false,
              selected: isSelected,
              onSelected: (_) => onDaySelected(index),
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.daysOfWeekShort[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.25)
                            : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

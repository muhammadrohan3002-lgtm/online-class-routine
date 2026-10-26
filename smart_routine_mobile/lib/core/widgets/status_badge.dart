import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.fontSize = 11,
  });

  factory StatusBadge.priority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const StatusBadge(
          label: 'High',
          backgroundColor: AppColors.errorContainer,
          textColor: AppColors.errorText,
          icon: Icons.priority_high_rounded,
        );
      case 'medium':
        return const StatusBadge(
          label: 'Medium',
          backgroundColor: AppColors.warningContainer,
          textColor: AppColors.warningText,
          icon: Icons.remove_rounded,
        );
      case 'low':
      default:
        return const StatusBadge(
          label: 'Low',
          backgroundColor: Color(0xFFE2E8F0),
          textColor: Color(0xFF475569),
          icon: Icons.keyboard_arrow_down_rounded,
        );
    }
  }

  factory StatusBadge.taskStatus({required bool isCompleted, required bool isOverdue}) {
    if (isCompleted) {
      return const StatusBadge(
        label: 'Completed',
        backgroundColor: AppColors.successContainer,
        textColor: AppColors.successText,
        icon: Icons.check_circle_rounded,
      );
    }
    if (isOverdue) {
      return const StatusBadge(
        label: 'Overdue',
        backgroundColor: AppColors.errorContainer,
        textColor: AppColors.errorText,
        icon: Icons.warning_rounded,
      );
    }
    return const StatusBadge(
      label: 'Pending',
      backgroundColor: AppColors.warningContainer,
      textColor: AppColors.warningText,
      icon: Icons.schedule_rounded,
    );
  }

  factory StatusBadge.attendance(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const StatusBadge(
          label: 'Present',
          backgroundColor: AppColors.successContainer,
          textColor: AppColors.successText,
          icon: Icons.check_circle_outline_rounded,
        );
      case 'absent':
        return const StatusBadge(
          label: 'Absent',
          backgroundColor: AppColors.errorContainer,
          textColor: AppColors.errorText,
          icon: Icons.cancel_outlined,
        );
      case 'late':
        return const StatusBadge(
          label: 'Late',
          backgroundColor: AppColors.warningContainer,
          textColor: AppColors.warningText,
          icon: Icons.access_time_rounded,
        );
      default:
        return StatusBadge(
          label: status.toUpperCase(),
          backgroundColor: const Color(0xFFE2E8F0),
          textColor: const Color(0xFF475569),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

class DateTimeUtils {
  /// Converts DateTime.weekday (Mon=1 ... Sun=7) to routine dayOfWeek (0=Sat ... 6=Fri).
  static int dateTimeToRoutineDay(DateTime dt) {
    switch (dt.weekday) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      case DateTime.friday:
        return 6;
      default:
        return 0;
    }
  }

  /// Converts routine dayOfWeek (0..6) to human-readable full day name (Saturday..Friday).
  static String getDayName(int dayOfWeek) {
    if (dayOfWeek >= 0 && dayOfWeek < AppStrings.daysOfWeek.length) {
      return AppStrings.daysOfWeek[dayOfWeek];
    }
    return 'Unknown';
  }

  /// Converts routine dayOfWeek (0..6) to short name (Sat..Fri).
  static String getDayNameShort(int dayOfWeek) {
    if (dayOfWeek >= 0 && dayOfWeek < AppStrings.daysOfWeekShort.length) {
      return AppStrings.daysOfWeekShort[dayOfWeek];
    }
    return '';
  }

  /// Formats 24h string ("14:30") to 12h format ("2:30 PM").
  static String formatTimeTo12Hour(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2026, 1, 1, hour, minute);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return time24;
    }
  }

  /// Formats TimeOfDay to 24h string ("09:05").
  static String timeOfDayToString(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Parses 24h string ("09:05") to TimeOfDay.
  static TimeOfDay stringToTimeOfDay(String time24) {
    try {
      final parts = time24.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  /// Converts "HH:mm" to total minutes since midnight.
  static int timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (_) {
      return 0;
    }
  }

  /// Returns friendly countdown string ("Today", "Tomorrow", "In 3 days", "Overdue").
  static String getCountdownString(String dateStr) {
    try {
      final targetDate = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

      final diffDays = target.difference(today).inDays;

      if (diffDays == 0) return 'Today';
      if (diffDays == 1) return 'Tomorrow';
      if (diffDays == -1) return 'Yesterday';
      if (diffDays < -1) return 'Overdue by ${diffDays.abs()} days';
      if (diffDays < 7) return 'In $diffDays days';
      if (diffDays < 30) {
        final weeks = (diffDays / 7).round();
        return 'In $weeks week${weeks > 1 ? 's' : ''}';
      }
      final months = (diffDays / 30).round();
      return 'In $months month${months > 1 ? 's' : ''}';
    } catch (_) {
      return dateStr;
    }
  }

  /// Formats YYYY-MM-DD date to nice readable string ("Mon, Oct 24, 2026").
  static String formatReadableDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d, yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  /// Formats DateTime to YYYY-MM-DD.
  static String toIsoDateString(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }
}

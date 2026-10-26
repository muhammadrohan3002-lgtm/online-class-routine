import '../../features/routine/models/routine_model.dart';
import 'date_time_utils.dart';

class ConflictResult {
  final bool hasConflict;
  final List<RoutineModel> conflicts;
  final String? warningMessage;

  const ConflictResult({
    required this.hasConflict,
    this.conflicts = const [],
    this.warningMessage,
  });

  static const noConflict = ConflictResult(hasConflict: false);
}

class ConflictDetector {
  /// Checks whether two time intervals [startA, endA) and [startB, endB) overlap.
  static bool doIntervalsOverlap(
    String startA,
    String endA,
    String startB,
    String endB,
  ) {
    final startMinsA = DateTimeUtils.timeToMinutes(startA);
    final endMinsA = DateTimeUtils.timeToMinutes(endA);
    final startMinsB = DateTimeUtils.timeToMinutes(startB);
    final endMinsB = DateTimeUtils.timeToMinutes(endB);

    return (startMinsA < endMinsB) && (endMinsA > startMinsB);
  }

  /// Evaluates an existing routine list on the target day for overlapping time conflicts.
  static ConflictResult checkRoutineConflict({
    required List<RoutineModel> existingRoutines,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? excludeRoutineId,
  }) {
    final sameDayRoutines = existingRoutines.where((r) {
      if (r.dayOfWeek != dayOfWeek) return false;
      if (excludeRoutineId != null && r.id == excludeRoutineId) return false;
      return true;
    }).toList();

    final conflicting = sameDayRoutines.where((r) {
      return doIntervalsOverlap(startTime, endTime, r.startTime, r.endTime);
    }).toList();

    if (conflicting.isEmpty) {
      return ConflictResult.noConflict;
    }

    final first = conflicting.first;
    final warning =
        'Schedule conflict detected! Overlaps with ${first.courseCode} (${DateTimeUtils.formatTimeTo12Hour(first.startTime)} - ${DateTimeUtils.formatTimeTo12Hour(first.endTime)} in ${first.room}).';

    return ConflictResult(
      hasConflict: true,
      conflicts: conflicting,
      warningMessage: warning,
    );
  }
}

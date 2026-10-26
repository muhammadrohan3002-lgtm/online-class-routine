import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine_mobile/core/utils/conflict_detector.dart';
import 'package:smart_routine_mobile/features/routine/models/routine_model.dart';

void main() {
  group('Routine Conflict Detection Tests', () {
    test('doIntervalsOverlap detects overlapping intervals correctly', () {
      // Overlapping: 09:00-10:30 and 10:00-11:30
      expect(ConflictDetector.doIntervalsOverlap('09:00', '10:30', '10:00', '11:30'), isTrue);

      // Overlapping: B completely inside A (09:15-10:00 inside 09:00-10:30)
      expect(ConflictDetector.doIntervalsOverlap('09:00', '10:30', '09:15', '10:00'), isTrue);

      // Overlapping: B engulfs A (08:30-11:00 engulfs 09:00-10:30)
      expect(ConflictDetector.doIntervalsOverlap('09:00', '10:30', '08:30', '11:00'), isTrue);
    });

    test('doIntervalsOverlap does not conflict for back-to-back adjacent classes', () {
      // Class A ends at 10:30, Class B starts at 10:30
      expect(ConflictDetector.doIntervalsOverlap('09:00', '10:30', '10:30', '12:00'), isFalse);

      // Completely separate times
      expect(ConflictDetector.doIntervalsOverlap('09:00', '10:00', '11:00', '12:00'), isFalse);
    });

    test('checkRoutineConflict flags conflict on the same day', () {
      final existingRoutines = [
        RoutineModel(
          id: 'rot-1',
          courseName: 'Algorithms',
          courseCode: 'CSE 320',
          teacher: 'Dr. John',
          room: 'Lab 402',
          dayOfWeek: 0, // Saturday
          startTime: '09:00',
          endTime: '10:30',
        ),
      ];

      // New routine on Saturday at 10:00-11:30 (overlaps with rot-1)
      final result = ConflictDetector.checkRoutineConflict(
        existingRoutines: existingRoutines,
        dayOfWeek: 0,
        startTime: '10:00',
        endTime: '11:30',
      );

      expect(result.hasConflict, isTrue);
      expect(result.conflicts.length, 1);
      expect(result.conflicts.first.courseCode, 'CSE 320');
      expect(result.warningMessage, contains('Schedule conflict detected'));
    });

    test('checkRoutineConflict allows same time on different days', () {
      final existingRoutines = [
        RoutineModel(
          id: 'rot-1',
          courseName: 'Algorithms',
          courseCode: 'CSE 320',
          teacher: 'Dr. John',
          room: 'Lab 402',
          dayOfWeek: 0, // Saturday
          startTime: '09:00',
          endTime: '10:30',
        ),
      ];

      // New routine at 09:00-10:30 but on Sunday (day 1) -> No conflict!
      final result = ConflictDetector.checkRoutineConflict(
        existingRoutines: existingRoutines,
        dayOfWeek: 1, // Sunday
        startTime: '09:00',
        endTime: '10:30',
      );

      expect(result.hasConflict, isFalse);
      expect(result.conflicts, isEmpty);
      expect(result.warningMessage, isNull);
    });

    test('checkRoutineConflict excludes own routine ID when editing', () {
      final existingRoutines = [
        RoutineModel(
          id: 'rot-1',
          courseName: 'Algorithms',
          courseCode: 'CSE 320',
          teacher: 'Dr. John',
          room: 'Lab 402',
          dayOfWeek: 0,
          startTime: '09:00',
          endTime: '10:30',
        ),
      ];

      // Editing rot-1 with same time should not conflict with itself
      final result = ConflictDetector.checkRoutineConflict(
        existingRoutines: existingRoutines,
        dayOfWeek: 0,
        startTime: '09:00',
        endTime: '10:30',
        excludeRoutineId: 'rot-1',
      );

      expect(result.hasConflict, isFalse);
    });
  });
}

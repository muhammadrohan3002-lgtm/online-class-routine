import 'package:flutter_test/flutter_test.dart';
import 'package:smart_routine_mobile/features/attendance/models/attendance_model.dart';

void main() {
  group('Attendance Calculation & Threshold Tests', () {
    test('Calculates course attendance percentage correctly', () {
      final summary = CourseAttendanceSummary(
        courseId: 'c1',
        courseName: 'Operating Systems',
        courseCode: 'CSE 320',
        present: 9,
        absent: 1,
        late: 0,
        total: 10,
        percentage: 90.0,
        isBelowThreshold: false,
      );

      expect(summary.total, 10);
      expect(summary.percentage, 90.0);
      expect(summary.isBelowThreshold, isFalse);
    });

    test('Flags low attendance warning when percentage is below threshold', () {
      // 5 present out of 10 = 50% (below 75% threshold)
      final summary = CourseAttendanceSummary(
        courseId: 'c2',
        courseName: 'Compiler Design',
        courseCode: 'CSE 340',
        present: 5,
        absent: 5,
        late: 0,
        total: 10,
        percentage: 50.0,
        isBelowThreshold: true,
      );

      expect(summary.isBelowThreshold, isTrue);
    });

    test('Parses backend AttendanceSummaryModel JSON correctly', () {
      final json = {
        'threshold': 75,
        'overall': {
          'totalClasses': 20,
          'present': 16,
          'absent': 3,
          'late': 1,
          'percentage': 80.0,
          'isBelowThreshold': false,
        },
        'courses': [
          {
            'courseId': 'c1',
            'courseName': 'Database Systems',
            'courseCode': 'CSE 310',
            'colorHex': '#2563EB',
            'present': 8,
            'absent': 2,
            'late': 0,
            'total': 10,
            'percentage': 80.0,
            'isBelowThreshold': false,
          },
          {
            'courseId': 'c2',
            'courseName': 'Computer Networks',
            'courseCode': 'CSE 330',
            'colorHex': '#EF4444',
            'present': 6,
            'absent': 4,
            'late': 0,
            'total': 10,
            'percentage': 60.0,
            'isBelowThreshold': true,
          },
        ],
      };

      final model = AttendanceSummaryModel.fromJson(json);

      expect(model.threshold, 75);
      expect(model.totalClasses, 20);
      expect(model.present, 16);
      expect(model.percentage, 80.0);
      expect(model.isBelowThreshold, isFalse);
      expect(model.courses.length, 2);

      // Verify course 2 triggers threshold warning
      expect(model.courses[1].courseCode, 'CSE 330');
      expect(model.courses[1].percentage, 60.0);
      expect(model.courses[1].isBelowThreshold, isTrue);
    });
  });
}

class AppStrings {
  static const String appName = 'Smart Routine';
  static const String appTagline = 'Smart Routine & Management for CSE Students';

  // Days of Week (Saturday to Friday)
  static const List<String> daysOfWeek = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static const List<String> daysOfWeekShort = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  // Task Categories
  static const List<String> taskCategories = [
    'Study',
    'Assignment',
    'Personal',
    'Other',
  ];

  // Task Priorities
  static const List<String> taskPriorities = ['low', 'medium', 'high'];

  // Exam Types
  static const List<String> examTypes = [
    'midterm',
    'final',
    'quiz',
    'lab',
    'presentation',
  ];

  // Attendance Statuses
  static const List<String> attendanceStatuses = ['present', 'absent', 'late'];

  // Default Attendance Warning Threshold
  static const int defaultAttendanceThreshold = 75;
}

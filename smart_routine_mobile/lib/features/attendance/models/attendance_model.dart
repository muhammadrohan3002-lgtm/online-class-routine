class AttendanceRecordModel {
  final String id;
  final String courseId;
  final String courseName;
  final String date; // YYYY-MM-DD
  final String status; // 'present', 'absent', 'late'
  final String notes;

  AttendanceRecordModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.date,
    required this.status,
    this.notes = '',
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'present',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }
}

class CourseAttendanceSummary {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String colorHex;
  final int present;
  final int absent;
  final int late;
  final int total;
  final double percentage;
  final bool isBelowThreshold;

  CourseAttendanceSummary({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    this.colorHex = '#2563EB',
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
    required this.percentage,
    required this.isBelowThreshold,
  });

  factory CourseAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return CourseAttendanceSummary(
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? '#2563EB',
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 100.0,
      isBelowThreshold: json['isBelowThreshold'] == true,
    );
  }
}

class AttendanceSummaryModel {
  final int threshold;
  final int totalClasses;
  final int present;
  final int absent;
  final int late;
  final double percentage;
  final bool isBelowThreshold;
  final List<CourseAttendanceSummary> courses;

  AttendanceSummaryModel({
    this.threshold = 75,
    required this.totalClasses,
    required this.present,
    required this.absent,
    required this.late,
    required this.percentage,
    required this.isBelowThreshold,
    required this.courses,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final overall = json['overall'] as Map<String, dynamic>? ?? {};
    final rawCourses = json['courses'] as List<dynamic>? ?? [];

    return AttendanceSummaryModel(
      threshold: (json['threshold'] as num?)?.toInt() ?? 75,
      totalClasses: (overall['totalClasses'] as num?)?.toInt() ?? 0,
      present: (overall['present'] as num?)?.toInt() ?? 0,
      absent: (overall['absent'] as num?)?.toInt() ?? 0,
      late: (overall['late'] as num?)?.toInt() ?? 0,
      percentage: (overall['percentage'] as num?)?.toDouble() ?? 100.0,
      isBelowThreshold: overall['isBelowThreshold'] == true,
      courses: rawCourses
          .map((c) => CourseAttendanceSummary.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

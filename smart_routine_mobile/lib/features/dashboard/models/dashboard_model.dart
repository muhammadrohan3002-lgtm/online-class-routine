import '../../routine/models/routine_model.dart';
import '../../tasks/models/task_model.dart';
import '../../calendar/models/exam_model.dart';

class NextClassModel {
  final String id;
  final String courseName;
  final String courseCode;
  final String room;
  final String teacher;
  final String startTime;
  final String endTime;
  final String colorHex;
  final bool isOngoing;

  NextClassModel({
    required this.id,
    required this.courseName,
    required this.courseCode,
    required this.room,
    required this.teacher,
    required this.startTime,
    required this.endTime,
    required this.colorHex,
    this.isOngoing = false,
  });

  factory NextClassModel.fromJson(Map<String, dynamic> json) {
    return NextClassModel(
      id: json['id']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? '#2563EB',
      isOngoing: json['isOngoing'] == true,
    );
  }
}

class AttendanceOverviewModel {
  final int totalRecorded;
  final int present;
  final int absent;
  final int late;
  final double percentage;
  final int threshold;
  final bool isBelowThreshold;

  AttendanceOverviewModel({
    required this.totalRecorded,
    required this.present,
    required this.absent,
    required this.late,
    required this.percentage,
    required this.threshold,
    required this.isBelowThreshold,
  });

  factory AttendanceOverviewModel.fromJson(Map<String, dynamic> json) {
    return AttendanceOverviewModel(
      totalRecorded: (json['totalRecorded'] as num?)?.toInt() ?? 0,
      present: (json['present'] as num?)?.toInt() ?? 0,
      absent: (json['absent'] as num?)?.toInt() ?? 0,
      late: (json['late'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 100.0,
      threshold: (json['threshold'] as num?)?.toInt() ?? 75,
      isBelowThreshold: json['isBelowThreshold'] == true,
    );
  }
}

class DashboardModel {
  final String greeting;
  final String todayDate;
  final int todayDayOfWeek;
  final int todayClassesCount;
  final NextClassModel? nextClass;
  final List<RoutineModel> todayClasses;
  final int pendingTasksCount;
  final List<TaskModel> pendingTasksPreview;
  final List<ExamModel> upcomingExams;
  final AttendanceOverviewModel attendanceOverview;

  DashboardModel({
    required this.greeting,
    required this.todayDate,
    required this.todayDayOfWeek,
    required this.todayClassesCount,
    this.nextClass,
    required this.todayClasses,
    required this.pendingTasksCount,
    required this.pendingTasksPreview,
    required this.upcomingExams,
    required this.attendanceOverview,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final rawTodayClasses = json['todayClasses'] as List<dynamic>? ?? [];
    final rawPendingTasks = json['pendingTasksPreview'] as List<dynamic>? ?? [];
    final rawExams = json['upcomingExams'] as List<dynamic>? ?? [];

    return DashboardModel(
      greeting: json['greeting']?.toString() ?? 'Welcome back',
      todayDate: json['todayDate']?.toString() ?? '',
      todayDayOfWeek: (json['todayDayOfWeek'] as num?)?.toInt() ?? 0,
      todayClassesCount: (json['todayClassesCount'] as num?)?.toInt() ?? 0,
      nextClass: json['nextClass'] != null
          ? NextClassModel.fromJson(json['nextClass'] as Map<String, dynamic>)
          : null,
      todayClasses: rawTodayClasses
          .map((c) => RoutineModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      pendingTasksCount: (json['pendingTasksCount'] as num?)?.toInt() ?? 0,
      pendingTasksPreview: rawPendingTasks
          .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      upcomingExams: rawExams
          .map((e) => ExamModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendanceOverview: AttendanceOverviewModel.fromJson(
        json['attendanceOverview'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

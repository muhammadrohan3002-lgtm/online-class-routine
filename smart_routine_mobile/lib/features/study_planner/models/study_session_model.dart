class StudySessionModel {
  final String id;
  final String? courseId;
  final String courseName;
  final String date; // YYYY-MM-DD
  final int targetMinutes;
  final int completedMinutes;
  final String notes;

  StudySessionModel({
    required this.id,
    this.courseId,
    required this.courseName,
    required this.date,
    this.targetMinutes = 60,
    this.completedMinutes = 0,
    this.notes = '',
  });

  double get progressPercentage {
    if (targetMinutes <= 0) return completedMinutes > 0 ? 100.0 : 0.0;
    return ((completedMinutes / targetMinutes) * 100).clamp(0.0, 100.0);
  }

  factory StudySessionModel.fromJson(Map<String, dynamic> json) {
    return StudySessionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString() ?? 'General Study',
      date: json['date']?.toString() ?? '',
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 60,
      completedMinutes: (json['completedMinutes'] as num?)?.toInt() ?? 0,
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (courseId != null) 'courseId': courseId,
      'courseName': courseName,
      'date': date,
      'targetMinutes': targetMinutes,
      'completedMinutes': completedMinutes,
      'notes': notes,
    };
  }

  StudySessionModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? date,
    int? targetMinutes,
    int? completedMinutes,
    String? notes,
  }) {
    return StudySessionModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      date: date ?? this.date,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      completedMinutes: completedMinutes ?? this.completedMinutes,
      notes: notes ?? this.notes,
    );
  }
}

class WeeklyStudyDayModel {
  final String date;
  final String day;
  final int completedMinutes;
  final int targetMinutes;
  final int percentage;

  WeeklyStudyDayModel({
    required this.date,
    required this.day,
    required this.completedMinutes,
    required this.targetMinutes,
    required this.percentage,
  });

  factory WeeklyStudyDayModel.fromJson(Map<String, dynamic> json) {
    return WeeklyStudyDayModel(
      date: json['date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      completedMinutes: (json['completedMinutes'] as num?)?.toInt() ?? 0,
      targetMinutes: (json['targetMinutes'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class StudyProgressModel {
  final int totalCompletedMinutes;
  final int totalTargetMinutes;
  final int overallProgressPercentage;
  final List<WeeklyStudyDayModel> weeklyBreakdown;

  StudyProgressModel({
    required this.totalCompletedMinutes,
    required this.totalTargetMinutes,
    required this.overallProgressPercentage,
    required this.weeklyBreakdown,
  });

  factory StudyProgressModel.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['weeklyBreakdown'] as List<dynamic>? ?? [];
    return StudyProgressModel(
      totalCompletedMinutes: (json['totalCompletedMinutes'] as num?)?.toInt() ?? 0,
      totalTargetMinutes: (json['totalTargetMinutes'] as num?)?.toInt() ?? 0,
      overallProgressPercentage:
          (json['overallProgressPercentage'] as num?)?.toInt() ?? 0,
      weeklyBreakdown: rawBreakdown
          .map((d) => WeeklyStudyDayModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

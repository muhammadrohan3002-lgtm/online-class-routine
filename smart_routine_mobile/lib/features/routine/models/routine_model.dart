class RoutineModel {
  final String id;
  final String? courseId;
  final String courseName;
  final String courseCode;
  final String teacher;
  final String room;
  final int dayOfWeek; // 0=Sat, 1=Sun, ..., 6=Fri
  final String startTime; // "09:00"
  final String endTime; // "10:30"
  final String colorHex;
  final String? conflictWarning;

  RoutineModel({
    required this.id,
    this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.teacher,
    required this.room,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.colorHex = '#2563EB',
    this.conflictWarning,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      courseId: json['courseId']?.toString(),
      courseName: json['courseName']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt() ?? 0,
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:30',
      colorHex: json['colorHex']?.toString() ?? '#2563EB',
      conflictWarning: json['conflictWarning']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (courseId != null) 'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'teacher': teacher,
      'room': room,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'colorHex': colorHex,
    };
  }

  RoutineModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? teacher,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? colorHex,
    String? conflictWarning,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorHex: colorHex ?? this.colorHex,
      conflictWarning: conflictWarning ?? this.conflictWarning,
    );
  }
}

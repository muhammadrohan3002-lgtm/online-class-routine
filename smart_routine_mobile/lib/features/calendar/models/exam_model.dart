class ExamModel {
  final String id;
  final String subject;
  final String type; // 'midterm', 'final', 'quiz', 'lab', 'presentation'
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final String location;
  final String notes;
  final int daysRemaining;
  final bool isPast;

  ExamModel({
    required this.id,
    required this.subject,
    this.type = 'quiz',
    required this.date,
    this.time = '10:00',
    this.location = 'Room TBA',
    this.notes = '',
    this.daysRemaining = 0,
    this.isPast = false,
  });

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'midterm':
        return 'Midterm Exam';
      case 'final':
        return 'Final Exam';
      case 'quiz':
        return 'Quiz';
      case 'lab':
        return 'Lab Exam';
      case 'presentation':
        return 'Presentation';
      default:
        return type.toUpperCase();
    }
  }

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      type: json['type']?.toString() ?? 'quiz',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '10:00',
      location: json['location']?.toString() ?? 'Room TBA',
      notes: json['notes']?.toString() ?? '',
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      isPast: json['isPast'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'type': type,
      'date': date,
      'time': time,
      'location': location,
      'notes': notes,
    };
  }

  ExamModel copyWith({
    String? id,
    String? subject,
    String? type,
    String? date,
    String? time,
    String? location,
    String? notes,
    int? daysRemaining,
    bool? isPast,
  }) {
    return ExamModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      isPast: isPast ?? this.isPast,
    );
  }
}

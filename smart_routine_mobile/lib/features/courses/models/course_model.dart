class CourseModel {
  final String id;
  final String name;
  final String code;
  final String teacher;
  final String room;
  final String colorHex;
  final int credits;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
    this.teacher = '',
    this.room = '',
    this.colorHex = '#2563EB',
    this.credits = 3,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
      colorHex: json['colorHex']?.toString() ?? '#2563EB',
      credits: (json['credits'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'teacher': teacher,
      'room': room,
      'colorHex': colorHex,
      'credits': credits,
    };
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? teacher,
    String? room,
    String? colorHex,
    int? credits,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      colorHex: colorHex ?? this.colorHex,
      credits: credits ?? this.credits,
    );
  }
}

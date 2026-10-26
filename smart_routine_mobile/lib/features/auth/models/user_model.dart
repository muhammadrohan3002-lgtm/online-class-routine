class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String institution;
  final int attendanceThreshold;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.studentId = '',
    this.department = '',
    this.institution = '',
    this.attendanceThreshold = 75,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      attendanceThreshold: (json['attendanceThreshold'] as num?)?.toInt() ?? 75,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'department': department,
      'institution': institution,
      'attendanceThreshold': attendanceThreshold,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? department,
    String? institution,
    int? attendanceThreshold,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      institution: institution ?? this.institution,
      attendanceThreshold: attendanceThreshold ?? this.attendanceThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

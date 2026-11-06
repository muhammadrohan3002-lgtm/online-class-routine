class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String department;
  final String institution;
  final int attendanceThreshold;
  final bool isGuest;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.studentId = '',
    this.department = '',
    this.institution = '',
    this.attendanceThreshold = 75,
    this.isGuest = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    final id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final isGuestFlag = json['isGuest'] == true ||
        email == 'guest@cse.edu' ||
        id == 'guest_user_offline_id';

    return UserModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: email,
      studentId: json['studentId']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      institution: json['institution']?.toString() ?? '',
      attendanceThreshold: (json['attendanceThreshold'] as num?)?.toInt() ?? 75,
      isGuest: isGuestFlag,
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
      'isGuest': isGuest,
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
    bool? isGuest,
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
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

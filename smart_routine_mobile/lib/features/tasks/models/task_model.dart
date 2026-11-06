class TaskModel {
  final String id;
  final String title;
  final String description;
  final String dueDate; // YYYY-MM-DD
  final String dueTime; // HH:mm
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'completed'
  final String category; // 'Study', 'Assignment', 'Personal', 'Other'
  final DateTime? completedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.dueTime = '',
    this.priority = 'medium',
    this.status = 'pending',
    this.category = 'Study',
    this.completedAt,
  });

  bool get isCompleted => status == 'completed';

  bool get isOverdue {
    if (isCompleted) return false;
    try {
      final due = DateTime.parse(dueDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return due.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      dueTime: json['dueTime']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'pending',
      category: json['category']?.toString() ?? 'Study',
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'priority': priority,
      'status': status,
      'category': category,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? dueDate,
    String? dueTime,
    String? priority,
    String? status,
    String? category,
    DateTime? completedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

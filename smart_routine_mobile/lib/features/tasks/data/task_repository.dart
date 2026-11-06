import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);

  Future<List<TaskModel>> getTasks({
    String? filter, // 'all', 'pending', 'completed', 'overdue'
    String? category,
    String? sortBy, // 'dueDate', 'priority'
  }) async {
    final params = <String, dynamic>{};
    if (filter != null && filter != 'all') params['filter'] = filter;
    if (category != null && category != 'All') params['category'] = category;
    if (sortBy != null) params['sortBy'] = sortBy;

    try {
      final res = await _apiClient.get(
        ApiEndpoints.tasks,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final list = res as List<dynamic>? ?? [];
      return list.map((t) => TaskModel.fromJson(t as Map<String, dynamic>)).toList();
    } catch (_) {
      final now = DateTime.now();
      String formatDate(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final sampleTasks = [
        TaskModel(
          id: 'guest_t1',
          title: 'Design SQL Schema for Library',
          description: 'Create normalized tables up to 3NF with keys',
          dueDate: formatDate(now.add(const Duration(days: 2))),
          dueTime: '23:59',
          priority: 'high',
          category: 'Assignment',
          status: 'pending',
        ),
        TaskModel(
          id: 'guest_t2',
          title: 'Read OS Process Scheduling Chapter',
          description: 'Review Round Robin, SJF, and Multi-Level Queue',
          dueDate: formatDate(now.add(const Duration(days: 4))),
          dueTime: '18:00',
          priority: 'medium',
          category: 'Study',
          status: 'pending',
        ),
        TaskModel(
          id: 'guest_t3',
          title: 'Wireshark Packet Analysis Lab Report',
          description: 'Capture TCP handshake and submit PDF report',
          dueDate: formatDate(now.subtract(const Duration(days: 1))),
          dueTime: '14:00',
          priority: 'high',
          category: 'Assignment',
          status: 'pending',
        ),
        TaskModel(
          id: 'guest_t4',
          title: 'Submit Group Project Proposal',
          description: 'Software Engineering SRS documentation draft',
          dueDate: formatDate(now.subtract(const Duration(days: 3))),
          dueTime: '16:00',
          priority: 'low',
          category: 'Study',
          status: 'completed',
        ),
      ];

      return sampleTasks.where((t) {
        if (filter == 'pending' && t.status != 'pending') return false;
        if (filter == 'completed' && t.status != 'completed') return false;
        if (filter == 'overdue' && !t.isOverdue) return false;
        if (category != null && category != 'All' && t.category != category) return false;
        return true;
      }).toList();
    }
  }

  Future<TaskModel> createTask({
    required String title,
    String? description,
    required String dueDate,
    String? dueTime,
    String priority = 'medium',
    String status = 'pending',
    String category = 'Study',
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.tasks,
      data: {
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'dueTime': dueTime,
        'priority': priority,
        'status': status,
        'category': category,
      },
    );
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  Future<TaskModel> updateTask(
    String id, {
    String? title,
    String? description,
    String? dueDate,
    String? dueTime,
    String? priority,
    String? status,
    String? category,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.tasks}/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (dueDate != null) 'dueDate': dueDate,
        if (dueTime != null) 'dueTime': dueTime,
        if (priority != null) 'priority': priority,
        if (status != null) 'status': status,
        if (category != null) 'category': category,
      },
    );
    return TaskModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    await _apiClient.delete('${ApiEndpoints.tasks}/$id');
  }
}

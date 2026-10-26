import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/exam_model.dart';

class ExamRepository {
  final ApiClient _apiClient;

  ExamRepository(this._apiClient);

  Future<List<ExamModel>> getExams({String? type, bool? upcomingOnly}) async {
    final params = <String, dynamic>{};
    if (type != null && type != 'all') params['type'] = type;
    if (upcomingOnly == true) params['upcoming'] = 'true';

    try {
      final res = await _apiClient.get(
        ApiEndpoints.exams,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final list = res as List<dynamic>? ?? [];
      return list.map((e) => ExamModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final now = DateTime.now();
      String formatDate(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      final sampleExams = [
        ExamModel(
          id: 'guest_e1',
          subject: 'CSE 311 - Database Systems',
          type: 'midterm',
          date: formatDate(now.add(const Duration(days: 7))),
          time: '10:00 AM',
          location: 'Auditorium Hall B',
          notes: 'Topics: ER diagrams, Relational Algebra, SQL, Normalization',
          daysRemaining: 7,
          isPast: false,
        ),
        ExamModel(
          id: 'guest_e2',
          subject: 'CSE 313 - Operating Systems',
          type: 'quiz',
          date: formatDate(now.add(const Duration(days: 3))),
          time: '11:00 AM',
          location: 'Room 501',
          notes: 'Critical section problem, Semaphores, Mutex locks, Deadlocks',
          daysRemaining: 3,
          isPast: false,
        ),
        ExamModel(
          id: 'guest_e3',
          subject: 'CSE 315 - Computer Networks',
          type: 'lab',
          date: formatDate(now.add(const Duration(days: 12))),
          time: '02:00 PM',
          location: 'Networking Lab 301',
          notes: 'Packet Tracer topology design, Subnetting, Socket programming in C',
          daysRemaining: 12,
          isPast: false,
        ),
      ];

      return sampleExams.where((e) {
        if (type != null && type != 'all' && e.type != type) return false;
        return true;
      }).toList();
    }
  }

  Future<ExamModel> createExam({
    required String subject,
    required String type,
    required String date,
    String? time,
    String? location,
    String? notes,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.exams,
      data: {
        'subject': subject,
        'type': type,
        'date': date,
        'time': time,
        'location': location,
        'notes': notes,
      },
    );
    return ExamModel.fromJson(res as Map<String, dynamic>);
  }

  Future<ExamModel> updateExam(
    String id, {
    String? subject,
    String? type,
    String? date,
    String? time,
    String? location,
    String? notes,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.exams}/$id',
      data: {
        if (subject != null) 'subject': subject,
        if (type != null) 'type': type,
        if (date != null) 'date': date,
        if (time != null) 'time': time,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      },
    );
    return ExamModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteExam(String id) async {
    await _apiClient.delete('${ApiEndpoints.exams}/$id');
  }
}

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/study_session_model.dart';

class StudySessionRepository {
  final ApiClient _apiClient;

  StudySessionRepository(this._apiClient);

  Future<List<StudySessionModel>> getSessions({String? date, String? courseId}) async {
    final params = <String, dynamic>{};
    if (date != null) params['date'] = date;
    if (courseId != null) params['courseId'] = courseId;

    final res = await _apiClient.get(
      ApiEndpoints.studySessions,
      queryParameters: params.isNotEmpty ? params : null,
    );
    final list = res as List<dynamic>? ?? [];
    return list.map((s) => StudySessionModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<StudyProgressModel> getProgress() async {
    final res = await _apiClient.get(ApiEndpoints.studyProgress);
    return StudyProgressModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudySessionModel> createSession({
    String? courseId,
    required String courseName,
    required String date,
    required int targetMinutes,
    int completedMinutes = 0,
    String? notes,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.studySessions,
      data: {
        if (courseId != null) 'courseId': courseId,
        'courseName': courseName,
        'date': date,
        'targetMinutes': targetMinutes,
        'completedMinutes': completedMinutes,
        'notes': notes,
      },
    );
    return StudySessionModel.fromJson(res as Map<String, dynamic>);
  }

  Future<StudySessionModel> updateSession(
    String id, {
    int? targetMinutes,
    int? completedMinutes,
    String? notes,
    String? date,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.studySessions}/$id',
      data: {
        if (targetMinutes != null) 'targetMinutes': targetMinutes,
        if (completedMinutes != null) 'completedMinutes': completedMinutes,
        if (notes != null) 'notes': notes,
        if (date != null) 'date': date,
      },
    );
    return StudySessionModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteSession(String id) async {
    await _apiClient.delete('${ApiEndpoints.studySessions}/$id');
  }
}

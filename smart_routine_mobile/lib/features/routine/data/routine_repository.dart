import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/routine_model.dart';

class RoutineRepository {
  final ApiClient _apiClient;

  RoutineRepository(this._apiClient);

  Future<List<RoutineModel>> getRoutines({int? dayOfWeek, String? courseId}) async {
    final params = <String, dynamic>{};
    if (dayOfWeek != null) params['day'] = dayOfWeek;
    if (courseId != null) params['courseId'] = courseId;

    try {
      final res = await _apiClient.get(
        ApiEndpoints.routines,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final list = res as List<dynamic>? ?? [];
      return list.map((r) => RoutineModel.fromJson(r as Map<String, dynamic>)).toList();
    } catch (_) {
      // Offline / Guest sample timetable
      final sampleRoutines = [
        RoutineModel(
          id: 'guest_r1',
          courseId: 'c1',
          courseCode: 'CSE 311',
          courseName: 'Database Management Systems',
          dayOfWeek: 0,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 402',
          teacher: 'Dr. Alan Turing',
          colorHex: '#4F46E5',
        ),
        RoutineModel(
          id: 'guest_r2',
          courseId: 'c2',
          courseCode: 'CSE 313',
          courseName: 'Operating Systems',
          dayOfWeek: 0,
          startTime: '10:45',
          endTime: '12:15',
          room: 'Room 501',
          teacher: 'Prof. Dennis Ritchie',
          colorHex: '#0EA5E9',
        ),
        RoutineModel(
          id: 'guest_r3',
          courseId: 'c3',
          courseCode: 'CSE 315',
          courseName: 'Computer Networks',
          dayOfWeek: 1,
          startTime: '09:00',
          endTime: '10:30',
          room: 'Lab 301',
          teacher: 'Dr. Vint Cerf',
          colorHex: '#10B981',
        ),
        RoutineModel(
          id: 'guest_r4',
          courseId: 'c1',
          courseCode: 'CSE 311',
          courseName: 'Database Management Systems',
          dayOfWeek: 2,
          startTime: '11:00',
          endTime: '12:30',
          room: 'Room 402',
          teacher: 'Dr. Alan Turing',
          colorHex: '#4F46E5',
        ),
        RoutineModel(
          id: 'guest_r5',
          courseId: 'c4',
          courseCode: 'CSE 317',
          courseName: 'Software Engineering',
          dayOfWeek: 3,
          startTime: '01:30',
          endTime: '03:00',
          room: 'Room 602',
          teacher: 'Dr. Margaret Hamilton',
          colorHex: '#F59E0B',
        ),
      ];

      return sampleRoutines.where((r) {
        if (dayOfWeek != null && r.dayOfWeek != dayOfWeek) return false;
        if (courseId != null && r.courseId != courseId) return false;
        return true;
      }).toList();
    }
  }

  Future<Map<String, dynamic>> checkConflict({
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? excludeId,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.routineConflict,
      data: {
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        if (excludeId != null) 'excludeId': excludeId,
      },
    );
    return res as Map<String, dynamic>;
  }

  Future<RoutineModel> createRoutine({
    String? courseId,
    required String courseName,
    required String courseCode,
    required String teacher,
    required String room,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? colorHex,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.routines,
      data: {
        if (courseId != null) 'courseId': courseId,
        'courseName': courseName,
        'courseCode': courseCode,
        'teacher': teacher,
        'room': room,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        if (colorHex != null) 'colorHex': colorHex,
      },
    );
    return RoutineModel.fromJson(res as Map<String, dynamic>);
  }

  Future<RoutineModel> updateRoutine(
    String id, {
    String? courseId,
    String? courseName,
    String? courseCode,
    String? teacher,
    String? room,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? colorHex,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.routines}/$id',
      data: {
        if (courseId != null) 'courseId': courseId,
        if (courseName != null) 'courseName': courseName,
        if (courseCode != null) 'courseCode': courseCode,
        if (teacher != null) 'teacher': teacher,
        if (room != null) 'room': room,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        if (colorHex != null) 'colorHex': colorHex,
      },
    );
    return RoutineModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteRoutine(String id) async {
    await _apiClient.delete('${ApiEndpoints.routines}/$id');
  }
}

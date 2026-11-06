import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<AttendanceSummaryModel> getSummary() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.attendanceSummary);
      return AttendanceSummaryModel.fromJson(res as Map<String, dynamic>);
    } catch (_) {
      return AttendanceSummaryModel(
        threshold: 75,
        percentage: 86.7,
        totalClasses: 30,
        present: 26,
        absent: 4,
        late: 0,
        isBelowThreshold: false,
        courses: [
          CourseAttendanceSummary(
            courseId: 'c1',
            courseName: 'Database Management Systems',
            courseCode: 'CSE 311',
            total: 10,
            present: 9,
            absent: 1,
            late: 0,
            percentage: 90.0,
            isBelowThreshold: false,
          ),
          CourseAttendanceSummary(
            courseId: 'c2',
            courseName: 'Operating Systems',
            courseCode: 'CSE 313',
            total: 10,
            present: 8,
            absent: 2,
            late: 0,
            percentage: 80.0,
            isBelowThreshold: false,
          ),
          CourseAttendanceSummary(
            courseId: 'c3',
            courseName: 'Computer Networks',
            courseCode: 'CSE 315',
            total: 10,
            present: 9,
            absent: 1,
            late: 0,
            percentage: 90.0,
            isBelowThreshold: false,
          ),
        ],
      );
    }
  }

  Future<List<AttendanceRecordModel>> getHistory({String? courseId, String? date}) async {
    final params = <String, dynamic>{};
    if (courseId != null) params['courseId'] = courseId;
    if (date != null) params['date'] = date;

    try {
      final res = await _apiClient.get(
        ApiEndpoints.attendance,
        queryParameters: params.isNotEmpty ? params : null,
      );
      final list = res as List<dynamic>? ?? [];
      return list.map((a) => AttendanceRecordModel.fromJson(a as Map<String, dynamic>)).toList();
    } catch (_) {
      final now = DateTime.now();
      String formatDate(DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      return [
        AttendanceRecordModel(
          id: 'guest_att_1',
          courseId: 'c1',
          courseName: 'Database Management Systems',
          date: formatDate(now.subtract(const Duration(days: 1))),
          status: 'present',
        ),
        AttendanceRecordModel(
          id: 'guest_att_2',
          courseId: 'c2',
          courseName: 'Operating Systems',
          date: formatDate(now.subtract(const Duration(days: 1))),
          status: 'present',
        ),
        AttendanceRecordModel(
          id: 'guest_att_3',
          courseId: 'c3',
          courseName: 'Computer Networks',
          date: formatDate(now.subtract(const Duration(days: 2))),
          status: 'absent',
        ),
      ];
    }
  }

  Future<AttendanceRecordModel> recordAttendance({
    required String courseId,
    required String courseName,
    required String date,
    required String status,
    String? notes,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.attendance,
      data: {
        'courseId': courseId,
        'courseName': courseName,
        'date': date,
        'status': status,
        'notes': notes,
      },
    );
    return AttendanceRecordModel.fromJson(res as Map<String, dynamic>);
  }

  Future<AttendanceRecordModel> updateRecord(
    String id, {
    String? status,
    String? notes,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.attendance}/$id',
      data: {
        if (status != null) 'status': status,
        if (notes != null) 'notes': notes,
      },
    );
    return AttendanceRecordModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteRecord(String id) async {
    await _apiClient.delete('${ApiEndpoints.attendance}/$id');
  }
}

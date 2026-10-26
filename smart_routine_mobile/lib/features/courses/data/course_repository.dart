import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository(this._apiClient);

  Future<List<CourseModel>> getCourses() async {
    final res = await _apiClient.get(ApiEndpoints.courses);
    final list = res as List<dynamic>? ?? [];
    return list.map((c) => CourseModel.fromJson(c as Map<String, dynamic>)).toList();
  }

  Future<CourseModel> createCourse({
    required String name,
    required String code,
    String? teacher,
    String? room,
    String? colorHex,
    int credits = 3,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.courses,
      data: {
        'name': name,
        'code': code,
        'teacher': teacher,
        'room': room,
        'colorHex': colorHex,
        'credits': credits,
      },
    );
    return CourseModel.fromJson(res as Map<String, dynamic>);
  }

  Future<CourseModel> updateCourse(
    String id, {
    String? name,
    String? code,
    String? teacher,
    String? room,
    String? colorHex,
    int? credits,
  }) async {
    final res = await _apiClient.put(
      '${ApiEndpoints.courses}/$id',
      data: {
        if (name != null) 'name': name,
        if (code != null) 'code': code,
        if (teacher != null) 'teacher': teacher,
        if (room != null) 'room': room,
        if (colorHex != null) 'colorHex': colorHex,
        if (credits != null) 'credits': credits,
      },
    );
    return CourseModel.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteCourse(String id) async {
    await _apiClient.delete('${ApiEndpoints.courses}/$id');
  }
}

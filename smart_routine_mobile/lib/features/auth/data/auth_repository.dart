import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<UserModel> login(String email, String password) async {
    final res = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final token = res['token']?.toString() ?? '';
    final userMap = res['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userMap);

    await _storageService.setToken(token);
    await _storageService.setUser(user);

    return user;
  }

  Future<UserModel> loginAsGuest() async {
    try {
      final res = await _apiClient.post(ApiEndpoints.guest);
      final token = res['token']?.toString() ?? 'guest_token';
      final userMap = res['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      await _storageService.setToken(token);
      await _storageService.setUser(user);
      return user;
    } catch (_) {
      // Offline fallback: if backend is unreachable, still permit instant guest access!
      final fallbackGuest = UserModel(
        id: 'guest_user_offline_id',
        name: 'Guest Student',
        email: 'guest@cse.edu',
        studentId: 'GUEST-2026',
        department: 'Computer Science & Engineering',
        institution: 'University of Engineering & Technology',
        attendanceThreshold: 75,
      );
      await _storageService.setToken('guest_token_offline');
      await _storageService.setUser(fallbackGuest);
      return fallbackGuest;
    }
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? department,
    String? institution,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'studentId': studentId,
        'department': department,
        'institution': institution,
      },
    );

    final token = res['token']?.toString() ?? '';
    final userMap = res['user'] as Map<String, dynamic>;
    final user = UserModel.fromJson(userMap);

    await _storageService.setToken(token);
    await _storageService.setUser(user);

    return user;
  }

  Future<UserModel> getProfile() async {
    final res = await _apiClient.get(ApiEndpoints.me);
    final user = UserModel.fromJson(res as Map<String, dynamic>);
    await _storageService.setUser(user);
    return user;
  }

  Future<UserModel> updateProfile({
    String? name,
    String? studentId,
    String? department,
    String? institution,
    int? attendanceThreshold,
    String? currentPassword,
    String? newPassword,
  }) async {
    final res = await _apiClient.put(
      ApiEndpoints.me,
      data: {
        if (name != null) 'name': name,
        if (studentId != null) 'studentId': studentId,
        if (department != null) 'department': department,
        if (institution != null) 'institution': institution,
        if (attendanceThreshold != null) 'attendanceThreshold': attendanceThreshold,
        if (currentPassword != null) 'currentPassword': currentPassword,
        if (newPassword != null) 'newPassword': newPassword,
      },
    );

    final user = UserModel.fromJson(res as Map<String, dynamic>);
    await _storageService.setUser(user);
    if (attendanceThreshold != null) {
      await _storageService.setAttendanceThreshold(attendanceThreshold);
    }
    return user;
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
    return res as Map<String, dynamic>;
  }

  Future<void> resetPassword({
    required String email,
    required String resetCode,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'email': email,
        'resetCode': resetCode,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> logout() async {
    await _storageService.clearSession();
  }

  UserModel? getCachedUser() => _storageService.getUser();
  bool isAuthenticated() => _storageService.hasToken();
}

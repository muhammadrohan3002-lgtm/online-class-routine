import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Compile-time environment override (e.g. flutter build --dart-define=API_URL=https://production.com/api)
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  // Candidate URLs for development
  static const String wifiLanUrl = 'http://192.168.0.102:5000/api';
  static const String adbReverseUrl = 'http://127.0.0.1:5000/api';
  static const String emulatorUrl = 'http://10.0.2.2:5000/api';
  static const String localhostUrl = 'http://localhost:5000/api';

  // Candidate URLs list for auto-discovery fallback
  static const List<String> candidateUrls = [
    wifiLanUrl,
    adbReverseUrl,
    emulatorUrl,
    localhostUrl,
  ];

  // Default development / production base URL
  static String get defaultBaseUrl {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    if (kIsWeb) return localhostUrl;
    // For Android physical devices, prefer Wi-Fi LAN IP (192.168.0.102) so the phone
    // connects over Wi-Fi without needing an active USB ADB reverse tunnel
    if (Platform.isAndroid) return wifiLanUrl;
    return localhostUrl;
  }

  // Active base URL (dynamic, can be updated via StorageService / ServerConfigScreen)
  static String baseUrl = defaultBaseUrl;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String guest = '/auth/guest';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Core endpoints
  static const String courses = '/courses';
  static const String routines = '/routines';
  static const String routineConflict = '/routines/check-conflict';
  static const String tasks = '/tasks';
  static const String exams = '/exams';
  static const String attendance = '/attendance';
  static const String attendanceSummary = '/attendance/summary';
  static const String studySessions = '/study-sessions';
  static const String studyProgress = '/study-sessions/progress';
  static const String dashboard = '/dashboard';
  static const String health = '/health';
}

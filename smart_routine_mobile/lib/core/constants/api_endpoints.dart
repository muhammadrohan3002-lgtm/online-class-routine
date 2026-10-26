import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Default development URLs (Phone Wi-Fi IP / Emulator / Web)
  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    // Use your PC's local Wi-Fi IP for physical phone connection
    if (Platform.isAndroid) return 'http://192.168.0.105:5000/api';
    return 'http://localhost:5000/api';
  }

  // Active base URL (dynamic, can be updated via StorageService)
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

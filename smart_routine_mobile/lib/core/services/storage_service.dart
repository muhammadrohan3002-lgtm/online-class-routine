import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../../features/auth/models/user_model.dart';

class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyBaseUrl = 'custom_base_url';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyThreshold = 'attendance_threshold';
  static const String _keyNotifications = 'notifications_enabled';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);

    // Sync saved custom base URL if present
    final savedUrl = service.getBaseUrl();
    if (savedUrl != null && savedUrl.isNotEmpty && savedUrl != 'http://127.0.0.1:5000/api') {
      ApiEndpoints.baseUrl = savedUrl;
    } else {
      ApiEndpoints.baseUrl = ApiEndpoints.defaultBaseUrl;
    }

    return service;
  }

  // Token management
  Future<bool> setToken(String token) async {
    return _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> removeToken() async {
    return _prefs.remove(_keyToken);
  }

  bool hasToken() {
    final t = getToken();
    return t != null && t.isNotEmpty;
  }

  // User management
  Future<bool> setUser(UserModel user) async {
    return _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeUser() async {
    return _prefs.remove(_keyUser);
  }

  // Custom Base URL
  Future<bool> setBaseUrl(String url) async {
    ApiEndpoints.baseUrl = url.trim();
    return _prefs.setString(_keyBaseUrl, url.trim());
  }

  String? getBaseUrl() {
    return _prefs.getString(_keyBaseUrl);
  }

  // Theme Mode
  Future<bool> setThemeMode(ThemeMode mode) async {
    return _prefs.setString(_keyThemeMode, mode.name);
  }

  ThemeMode getThemeMode() {
    final name = _prefs.getString(_keyThemeMode);
    if (name == 'light') return ThemeMode.light;
    if (name == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  // Attendance Threshold
  Future<bool> setAttendanceThreshold(int threshold) async {
    return _prefs.setInt(_keyThreshold, threshold);
  }

  int getAttendanceThreshold() {
    return _prefs.getInt(_keyThreshold) ?? 75;
  }

  // Notifications enabled
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return _prefs.setBool(_keyNotifications, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_keyNotifications) ?? true;
  }

  // Full clear on logout
  Future<void> clearSession() async {
    await removeToken();
    await removeUser();
  }
}

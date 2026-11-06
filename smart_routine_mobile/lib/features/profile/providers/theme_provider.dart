import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/storage_service.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final StorageService _storageService;

  ThemeNotifier(this._storageService) : super(_storageService.getThemeMode());

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _storageService.setThemeMode(mode);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ThemeNotifier(storage);
});

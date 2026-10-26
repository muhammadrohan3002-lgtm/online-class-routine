import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette: Calm Blue & Indigo
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryContainer = Color(0xFFDBEAFE);

  static const Color secondary = Color(0xFF4F46E5); // Indigo
  static const Color secondaryContainer = Color(0xFFE0E7FF);

  static const Color accent = Color(0xFF06B6D4); // Cyan

  // Surface & Background - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFF1F5F9);

  // Surface & Background - Dark Mode
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF1E293B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald (Present, Completed)
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B); // Amber (Late, Pending, Warning)
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444); // Rose/Red (Absent, Overdue, Danger)
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color errorText = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFEFF6FF);

  // Curated Course / Tag Palette (for color-coding courses and routines)
  static const List<Color> coursePalette = [
    Color(0xFF2563EB), // Blue
    Color(0xFF4F46E5), // Indigo
    Color(0xFF7C3AED), // Purple
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFFDC2626), // Crimson
    Color(0xFF0891B2), // Cyan
    Color(0xFFDB2777), // Pink
    Color(0xFF475569), // Slate
  ];

  static Color hexToColor(String? hexString, {Color defaultColor = primary}) {
    if (hexString == null || hexString.isEmpty) return defaultColor;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

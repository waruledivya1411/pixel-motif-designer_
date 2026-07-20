import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's [ThemeMode] choice across app launches.
///
/// Keeps platform I/O out of [ThemeProvider] so theme state stays testable
/// and swappable (e.g. mock preferences in widget tests).
abstract final class ThemePreferences {
  static const _storageKey = 'theme_mode';

  /// Loads the saved theme mode, or [ThemeMode.system] on first launch.
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored == null) {
      return ThemeMode.system;
    }
    return _decode(stored) ?? ThemeMode.system;
  }

  /// Writes the selected mode so it survives process restarts.
  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _encode(mode));
  }

  /// User-facing label shown in the drawer and appearance sheet.
  static String labelFor(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Light Mode',
      ThemeMode.dark => 'Dark Mode',
      ThemeMode.system => 'System Default',
    };
  }

  static String _encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static ThemeMode? _decode(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}

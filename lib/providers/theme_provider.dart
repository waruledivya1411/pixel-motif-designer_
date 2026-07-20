import 'package:flutter/material.dart';

import '../services/theme_preferences.dart';

/// Owns application-wide [ThemeMode] state.
///
/// Isolated from canvas/drawing providers so theme changes never trigger
/// grid repaints or export-related rebuilds through shared listeners.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeMode initialThemeMode = ThemeMode.system})
      : _themeMode = initialThemeMode;

  ThemeMode _themeMode;

  /// Active theme mode (light, dark, or follow system).
  ThemeMode get themeMode => _themeMode;

  /// Human-readable label for drawer subtitle and appearance UI.
  String get themeModeLabel => ThemePreferences.labelFor(_themeMode);

  /// Updates theme, notifies listeners, and persists the choice.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }
    _themeMode = mode;
    notifyListeners();
    await ThemePreferences.saveThemeMode(mode);
  }
}

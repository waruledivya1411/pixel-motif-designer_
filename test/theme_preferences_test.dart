import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pixel_motif_designer/services/theme_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loadThemeMode returns system when nothing is stored', () async {
    expect(await ThemePreferences.loadThemeMode(), ThemeMode.system);
  });

  test('save and load round-trip preserves theme mode', () async {
    await ThemePreferences.saveThemeMode(ThemeMode.dark);
    expect(await ThemePreferences.loadThemeMode(), ThemeMode.dark);
  });

  test('labelFor returns user-facing strings', () {
    expect(ThemePreferences.labelFor(ThemeMode.light), 'Light Mode');
    expect(ThemePreferences.labelFor(ThemeMode.dark), 'Dark Mode');
    expect(ThemePreferences.labelFor(ThemeMode.system), 'System Default');
  });
}

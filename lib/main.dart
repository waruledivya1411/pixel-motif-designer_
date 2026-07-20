import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/theme_preferences.dart';

/// Application entry point.
///
/// Keeps bootstrap concerns isolated: binding initialization, orientation,
/// and launching the root widget. No business logic lives here.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for a consistent canvas experience on phones.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final initialThemeMode = await ThemePreferences.loadThemeMode();

  runApp(PixelMotifApp(initialThemeMode: initialThemeMode));
}

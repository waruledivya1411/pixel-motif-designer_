import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'services/theme_preferences.dart';

/// Application entry point.
///
/// Keeps bootstrap concerns isolated: binding initialization, orientation,
/// and launching the root widget. No business logic lives here.
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock to portrait for a consistent canvas experience on phones.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final initialThemeMode = await ThemePreferences.loadThemeMode();

  runApp(PixelMotifApp(initialThemeMode: initialThemeMode));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';

/// Root widget that wires theme, routing shell, and global providers.
///
/// [PixelMotifApp] is intentionally thin — it configures presentation concerns
/// only and delegates feature state to the provider layer.
class PixelMotifApp extends StatelessWidget {
  const PixelMotifApp({
    super.key,
    this.initialThemeMode = ThemeMode.system,
  });

  /// Restored from [ThemePreferences] before the first frame is drawn.
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      initialThemeMode: initialThemeMode,
      child: const _ThemedMaterialApp(),
    );
  }
}

/// Listens to [ThemeProvider] only — canvas providers are unaffected.
class _ThemedMaterialApp extends StatelessWidget {
  const _ThemedMaterialApp();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (provider) => provider.themeMode,
    );

    return MaterialApp(
      title: 'Pixel Motif Designer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

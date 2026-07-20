import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/home/home_screen.dart';

/// Root widget that wires theme, routing shell, and global providers.
///
/// [PixelMotifApp] is intentionally thin — it configures presentation concerns
/// only and delegates feature state to the provider layer.
class PixelMotifApp extends StatelessWidget {
  const PixelMotifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        title: 'Pixel Motif Designer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}

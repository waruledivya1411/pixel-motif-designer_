import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'canvas_provider.dart';
import 'motif_provider.dart';
import 'palette_provider.dart';
import 'theme_provider.dart';

/// Registers all application-level [ChangeNotifier] providers.
///
/// Centralizing provider setup here makes dependency wiring explicit,
/// testable, and easy to extend as new features are added.
class AppProviders extends StatelessWidget {
  const AppProviders({
    super.key,
    required this.child,
    this.initialThemeMode = ThemeMode.system,
  });

  /// Widget subtree that receives provider access via [context.read] /
  /// [context.watch].
  final Widget child;

  /// Theme mode loaded before [runApp] to avoid a flash on cold start.
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(initialThemeMode: initialThemeMode),
        ),
        ChangeNotifierProvider(create: (_) => CanvasProvider()),
        ChangeNotifierProvider(create: (_) => PaletteProvider()),
        ChangeNotifierProvider(create: (_) => MotifProvider()),
      ],
      child: child,
    );
  }
}

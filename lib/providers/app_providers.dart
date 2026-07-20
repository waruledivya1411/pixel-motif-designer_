import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'grid_provider.dart';
import 'motif_provider.dart';
import 'palette_provider.dart';

/// Registers all application-level [ChangeNotifier] providers.
///
/// Centralizing provider setup here makes dependency wiring explicit,
/// testable, and easy to extend as new features are added.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  /// Widget subtree that receives provider access via [context.read] /
  /// [context.watch].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GridProvider()),
        ChangeNotifierProvider(create: (_) => PaletteProvider()),
        ChangeNotifierProvider(create: (_) => MotifProvider()),
      ],
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// Semantic color tokens for the application theme.
///
/// Separating raw color values from [ThemeData] construction keeps
/// the theme layer easy to extend for dark mode later.
abstract final class AppColors {
  /// Primary brand blue — app bar, buttons, and accents.
  static const Color primary = Color(0xFF1976D2);

  /// Soft blue wash for drawer, headers, and selected states.
  static const Color primaryContainer = Color(0xFFE3F2FD);

  /// Text and icons on primary blue surfaces.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Text on light blue containers.
  static const Color onPrimaryContainer = Color(0xFF0D47A1);

  /// Page background — muted so elevated cards read clearly.
  static const Color background = Color(0xFFE1E8F2);

  /// Elevated surface color for cards, panels, and nav tiles.
  static const Color surface = Color(0xFFFFFFFF);

  /// Nested surface inside cards (tool chips, previews).
  static const Color surfaceContainer = Color(0xFFF0F4FA);

  /// Primary body text color.
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Secondary / hint text color.
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Subtle divider and outline color — strong enough to frame white cards.
  static const Color outline = Color(0xFF90A4C6);

  // ---------------------------------------------------------------------------
  // Dark theme tokens — mirror light semantics for Material 3 dark surfaces.
  // ---------------------------------------------------------------------------

  /// Dark scaffold background.
  static const Color darkBackground = Color(0xFF0D1117);

  /// Dark elevated surface for cards, drawer, and app bar.
  static const Color darkSurface = Color(0xFF1A2332);

  /// Nested surface inside dark cards.
  static const Color darkSurfaceContainer = Color(0xFF243044);

  /// Primary accent tuned for dark surfaces.
  static const Color darkPrimary = Color(0xFF90CAF9);

  /// Blue-tinted container for drawer and selected states in dark mode.
  static const Color darkPrimaryContainer = Color(0xFF1E3A5F);

  /// High-contrast text on dark primary actions.
  static const Color darkOnPrimary = Color(0xFF0A1929);

  /// Text on dark blue containers.
  static const Color darkOnPrimaryContainer = Color(0xFFE3F2FD);

  /// Primary body text on dark surfaces.
  static const Color darkOnSurface = Color(0xFFE6E1E5);

  /// Secondary text on dark surfaces.
  static const Color darkOnSurfaceVariant = Color(0xFFB0BEC5);

  /// Outline and dividers on dark surfaces.
  static const Color darkOutline = Color(0xFF546E7A);
}

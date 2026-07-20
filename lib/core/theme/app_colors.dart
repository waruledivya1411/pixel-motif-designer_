import 'package:flutter/material.dart';

/// Semantic color tokens for the application theme.
///
/// Separating raw color values from [ThemeData] construction keeps
/// the theme layer easy to extend for dark mode later.
abstract final class AppColors {
  /// Primary brand color — used for key actions and accents.
  static const Color primary = Color(0xFF5C6BC0);

  /// Lighter variant for containers and selected states.
  static const Color primaryContainer = Color(0xFFE8EAF6);

  /// High-contrast text on primary surfaces.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Page background — intentionally muted so elevated cards read clearly.
  static const Color background = Color(0xFFE1E4EC);

  /// Elevated surface color for cards, drawer panels, and app bar.
  static const Color surface = Color(0xFFFFFFFF);

  /// Nested surface inside cards (tool chips, previews).
  static const Color surfaceContainer = Color(0xFFF3F4F8);

  /// Primary body text color.
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Secondary / hint text color.
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Subtle divider and outline color — strong enough to frame white cards.
  static const Color outline = Color(0xFFB4BAC8);

  // ---------------------------------------------------------------------------
  // Dark theme tokens — mirror light semantics for Material 3 dark surfaces.
  // ---------------------------------------------------------------------------

  /// Dark scaffold background.
  static const Color darkBackground = Color(0xFF0F1114);

  /// Dark elevated surface for cards, drawer, and app bar.
  static const Color darkSurface = Color(0xFF2A2D34);

  /// Nested surface inside dark cards.
  static const Color darkSurfaceContainer = Color(0xFF353841);

  /// Primary accent tuned for dark surfaces.
  static const Color darkPrimary = Color(0xFFAAB4FF);

  /// Container tint for selected states on dark surfaces.
  static const Color darkPrimaryContainer = Color(0xFF3F4777);

  /// High-contrast text on dark primary actions.
  static const Color darkOnPrimary = Color(0xFF1A1B2E);

  /// Primary body text on dark surfaces.
  static const Color darkOnSurface = Color(0xFFE6E1E5);

  /// Secondary text on dark surfaces.
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

  /// Outline and dividers on dark surfaces.
  static const Color darkOutline = Color(0xFF6E7585);
}

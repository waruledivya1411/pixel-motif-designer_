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

  /// Default scaffold and surface background.
  static const Color background = Color(0xFFFAFAFA);

  /// Elevated surface color for cards and panels.
  static const Color surface = Color(0xFFFFFFFF);

  /// Primary body text color.
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Secondary / hint text color.
  static const Color onSurfaceVariant = Color(0xFF49454F);

  /// Subtle divider and outline color.
  static const Color outline = Color(0xFFCAC4D0);
}

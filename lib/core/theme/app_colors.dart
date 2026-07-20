import 'package:flutter/material.dart';

/// Semantic color tokens for the application theme.
///
/// Light mode uses confident Material Blue branding; dark mode uses neutral
/// slate surfaces with a soft accent so night viewing stays comfortable.
abstract final class AppColors {
  /// Primary brand blue — app bar, buttons, and accents (light mode).
  static const Color primary = Color(0xFF1976D2);

  /// Soft blue wash for drawer, headers, and selected states (light mode).
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
  // Dark theme — neutral slate base with restrained blue accent (not day-blue).
  // ---------------------------------------------------------------------------

  /// Dark scaffold background.
  static const Color darkBackground = Color(0xFF0F1218);

  /// Dark elevated surface for cards and panels.
  static const Color darkSurface = Color(0xFF1A1F28);

  /// App bar surface — slightly elevated from [darkSurface].
  static const Color darkAppBar = Color(0xFF222831);

  /// Nested surface inside dark cards.
  static const Color darkSurfaceContainer = Color(0xFF2A303C);

  /// Soft accent for buttons, icons, and progress (not a bright day-blue).
  static const Color darkPrimary = Color(0xFF6EA8FE);

  /// Subtle chip / container tint — charcoal with a hint of cool tone.
  static const Color darkPrimaryContainer = Color(0xFF2D3644);

  /// Text on filled accent buttons in dark mode.
  static const Color darkOnPrimary = Color(0xFF0F1218);

  /// Text on dark tinted containers.
  static const Color darkOnPrimaryContainer = Color(0xFFB8C5D9);

  /// Primary body text on dark surfaces.
  static const Color darkOnSurface = Color(0xFFE8EAED);

  /// Secondary text on dark surfaces.
  static const Color darkOnSurfaceVariant = Color(0xFF9AA3AF);

  /// Outline and dividers on dark surfaces.
  static const Color darkOutline = Color(0xFF3A424F);
}

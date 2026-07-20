/// Application-wide layout and identity constants.
///
/// Values shared across multiple features that are not grid-specific
/// belong here to avoid duplication.
abstract final class AppConstants {
  /// Display name shown in the app bar and system UI.
  static const String appName = 'Pixel Motif Designer';

  /// Semantic version shown in About.
  static const String appVersion = '1.0.0';

  /// Application author.
  static const String appAuthor = 'Divya Warule';

  /// Short description for About and store listings.
  static const String appDescription =
      'A production-quality pixel art studio for creating, editing, and exporting motif designs on your phone.';

  /// Contact email shown in About.
  static const String appContactEmail = 'waruledivya14@gmail.com';

  /// Highlighted capabilities shown in the About sheet.
  static const List<String> appFeatures = [
    'Draw & drag paint on 16×16 or 32×32 grids',
    'Eraser, clear canvas, undo & redo (30 steps)',
    'Custom HSV color picker + preset palette',
    'Built-in pixel templates gallery',
    'Export PNG to gallery & SVG to Downloads',
    'Light, dark, and system appearance modes',
    'Live canvas usage counter',
  ];

  /// Standard horizontal padding for screen content.
  static const double paddingSmall = 8.0;

  /// Default padding used by scaffolds, panels, and toolbars.
  static const double paddingMedium = 16.0;

  /// Larger spacing for section separation.
  static const double paddingLarge = 24.0;

  /// Corner radius applied to cards and panels.
  static const double borderRadius = 12.0;

  /// Vertical gap between major editor sections.
  static const double sectionSpacing = 12.0;

  /// Maximum content width on large screens for readable layout.
  static const double maxContentWidth = 440.0;

  /// Minimum recommended touch target (Material accessibility).
  static const double minTouchTarget = 48.0;
}

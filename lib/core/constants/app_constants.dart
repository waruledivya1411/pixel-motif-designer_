/// Application-wide layout and identity constants.
///
/// Values shared across multiple features that are not grid-specific
/// belong here to avoid duplication.
abstract final class AppConstants {
  /// Display name shown in the app bar and system UI.
  static const String appName = 'Pixel Motif Designer';

  /// Standard horizontal padding for screen content.
  static const double paddingSmall = 8.0;

  /// Default padding used by scaffolds, panels, and toolbars.
  static const double paddingMedium = 16.0;

  /// Larger spacing for section separation.
  static const double paddingLarge = 24.0;

  /// Corner radius applied to cards and panels.
  static const double borderRadius = 12.0;
}

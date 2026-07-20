/// Result of an export attempt surfaced to the UI layer.
enum ExportResult {
  /// Image was saved to the gallery or filesystem successfully.
  success,

  /// Export failed due to an unexpected error.
  failure,
}

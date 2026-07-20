/// Grid and cell sizing constants for the pixel motif canvas.
///
/// Centralizing these values ensures the UI, gesture math, and export
/// pipeline stay aligned as features are implemented.
abstract final class GridConstants {
  /// Default number of columns in the motif grid.
  static const int defaultGridSize = 16;

  /// Default number of rows in the motif grid.
  static const int defaultRowCount = defaultGridSize;

  /// Square grid dimensions offered in the grid size selector.
  static const List<int> supportedGridSizes = [defaultGridSize, 32];

  /// Logical pixel size of a single grid cell on screen.
  static const double defaultCellSize = 20.0;

  /// Minimum allowed cell size when zooming out.
  static const double minCellSize = 8.0;

  /// Maximum allowed cell size when zooming in.
  static const double maxCellSize = 48.0;

  /// Logical pixel size of each cell in exported PNG images.
  static const int exportCellPixelSize = 16;
}

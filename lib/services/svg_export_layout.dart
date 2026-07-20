import '../core/constants/grid_constants.dart';
import '../models/canvas_state.dart';

/// Computes SVG viewport and pixel-rect geometry from a [CanvasState] snapshot.
///
/// Centralizes export sizing so width, height, viewBox, and every `<rect>`
/// share one coordinate system derived from grid dimensions — never from
/// screen size or device metrics.
final class SvgExportLayout {
  const SvgExportLayout({
    required this.columns,
    required this.rows,
    required this.cellPixelSize,
  });

  /// Number of grid columns in the exported canvas.
  final int columns;

  /// Number of grid rows in the exported canvas.
  final int rows;

  /// Edge length of each exported pixel in SVG user units (typically px).
  final int cellPixelSize;

  /// Total SVG width: [columns] × [cellPixelSize].
  int get width => columns * cellPixelSize;

  /// Total SVG height: [rows] × [cellPixelSize].
  int get height => rows * cellPixelSize;

  /// Viewport covering the full motif canvas with no padding or offset.
  String get viewBox => '0 0 $width $height';

  /// Width attribute for the root `<svg>` element.
  String get widthAttribute => '${width}px';

  /// Height attribute for the root `<svg>` element.
  String get heightAttribute => '${height}px';

  /// Top-left position and size for the pixel at [row] and [column].
  ///
  /// Uses zero-based grid indices — the same coordinate space as drawing.
  ({int x, int y, int width, int height}) rectForCell({
    required int row,
    required int column,
  }) {
    return (
      x: column * cellPixelSize,
      y: row * cellPixelSize,
      width: cellPixelSize,
      height: cellPixelSize,
    );
  }

  /// Builds layout metadata from [state] using the shared export cell size.
  factory SvgExportLayout.fromCanvasState(CanvasState state) {
    return SvgExportLayout(
      columns: state.gridColumns,
      rows: state.gridRows,
      cellPixelSize: GridConstants.exportCellPixelSize,
    );
  }
}

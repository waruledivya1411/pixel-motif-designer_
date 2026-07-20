import '../core/constants/grid_constants.dart';
import 'drawing_tool.dart';
import 'pixel.dart';

/// Immutable snapshot of everything needed to describe the motif canvas.
///
/// [CanvasState] is the aggregate root for drawing data. Providers will mutate
/// state by producing new [CanvasState] instances via [copyWith], which keeps
/// undo/redo implementation as simple as pushing/popping snapshots onto a list.
class CanvasState {
  CanvasState({
    required this.gridRows,
    required this.gridColumns,
    required this.activeColor,
    required this.selectedTool,
    required List<List<Pixel>> pixels,
  })  : assert(gridRows > 0, 'gridRows must be greater than zero'),
        assert(gridColumns > 0, 'gridColumns must be greater than zero'),
        assert(
          pixels.length == gridRows,
          'Pixel matrix row count must match gridRows',
        ),
        pixels = _deepUnmodifiable(pixels) {
    for (var row = 0; row < pixels.length; row++) {
      assert(
        pixels[row].length == gridColumns,
        'Pixel matrix column count must match gridColumns at row $row',
      );
    }
  }

  /// Number of rows in the grid.
  ///
  /// Exposed separately from [gridColumns] so rectangular grids can be
  /// supported later without restructuring this model.
  final int gridRows;

  /// Number of columns in the grid.
  final int gridColumns;

  /// Convenience accessor when the grid is square ([gridRows] == [gridColumns]).
  int get gridSize => gridRows;

  /// Whether the grid is square.
  bool get isSquareGrid => gridRows == gridColumns;

  /// Currently selected paint color (32-bit ARGB).
  final int activeColor;

  /// Active interaction tool (draw, erase, etc.).
  final DrawingTool selectedTool;

  /// Default paint color (black) — aligned with the first palette swatch.
  static const int defaultActiveColor = 0xFF000000;

  /// Two-dimensional pixel matrix indexed as [pixels][row][column].
  ///
  /// The outer list length equals [gridRows]; each inner list length equals
  /// [gridColumns].
  final List<List<Pixel>> pixels;

  /// Returns the pixel at [row] and [column], or `null` if out of bounds.
  Pixel? pixelAt(int row, int column) {
    if (row < 0 || row >= gridRows || column < 0 || column >= gridColumns) {
      return null;
    }
    return pixels[row][column];
  }

  /// Total number of filled pixels on the canvas.
  int get filledPixelCount {
    var count = 0;
    for (final row in pixels) {
      for (final pixel in row) {
        if (pixel.isFilled) count++;
      }
    }
    return count;
  }

  /// Creates the default empty canvas using shared app constants.
  factory CanvasState.initial({
    int? gridRows,
    int? gridColumns,
    int? activeColor,
    DrawingTool? selectedTool,
  }) {
    final rows = gridRows ?? GridConstants.defaultRowCount;
    final columns = gridColumns ?? GridConstants.defaultGridSize;

    return CanvasState(
      gridRows: rows,
      gridColumns: columns,
      activeColor: activeColor ?? defaultActiveColor,
      selectedTool: selectedTool ?? DrawingTool.draw,
      pixels: _buildEmptyMatrix(rows, columns),
    );
  }

  /// Returns a new [CanvasState] with selectively replaced fields.
  ///
  /// When [pixels] is supplied, it replaces the entire matrix — enabling
  /// future undo/redo or batch-update logic without mutating existing state.
  CanvasState copyWith({
    int? gridRows,
    int? gridColumns,
    int? activeColor,
    DrawingTool? selectedTool,
    List<List<Pixel>>? pixels,
  }) {
    return CanvasState(
      gridRows: gridRows ?? this.gridRows,
      gridColumns: gridColumns ?? this.gridColumns,
      activeColor: activeColor ?? this.activeColor,
      selectedTool: selectedTool ?? this.selectedTool,
      pixels: pixels ?? this.pixels,
    );
  }

  /// Returns a new matrix with a single cell updated at [row], [column].
  ///
  /// Intended for provider-layer draw/erase handlers; kept on the model so
  /// matrix copying rules live in one place.
  CanvasState withPixelAt(int row, int column, Pixel pixel) {
    assert(row >= 0 && row < gridRows, 'row out of bounds');
    assert(column >= 0 && column < gridColumns, 'column out of bounds');
    assert(pixel.row == row && pixel.column == column, 'pixel coordinates mismatch');

    final updatedMatrix = [
      for (var r = 0; r < gridRows; r++)
        [
          for (var c = 0; c < gridColumns; c++)
            (r == row && c == column) ? pixel : pixels[r][c],
        ],
    ];

    return copyWith(pixels: updatedMatrix);
  }

  static List<List<Pixel>> _buildEmptyMatrix(int rows, int columns) {
    return List.generate(
      rows,
      (row) => List.generate(
        columns,
        (column) => Pixel.empty(row: row, column: column),
      ),
    );
  }

  static List<List<Pixel>> _deepUnmodifiable(List<List<Pixel>> source) {
    return List.unmodifiable(
      source.map(List<Pixel>.unmodifiable),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasState &&
        other.gridRows == gridRows &&
        other.gridColumns == gridColumns &&
        other.activeColor == activeColor &&
        other.selectedTool == selectedTool &&
        _matrixEquals(other.pixels, pixels);
  }

  @override
  int get hashCode => Object.hash(
        gridRows,
        gridColumns,
        activeColor,
        selectedTool,
        _matrixHash(pixels),
      );

  static bool _matrixEquals(List<List<Pixel>> a, List<List<Pixel>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return false;
      for (var j = 0; j < a[i].length; j++) {
        if (a[i][j] != b[i][j]) return false;
      }
    }
    return true;
  }

  static int _matrixHash(List<List<Pixel>> matrix) {
    return Object.hashAll(
      matrix.expand((row) => row),
    );
  }

  @override
  String toString() =>
      'CanvasState(gridRows: $gridRows, gridColumns: $gridColumns, activeColor: 0x${activeColor.toRadixString(16).padLeft(8, '0')}, selectedTool: $selectedTool, filledPixelCount: $filledPixelCount)';
}

/// Immutable pixel-matrix snapshot stored on the undo/redo stacks.
///
/// Captures grid dimensions and cell data only — [activeColor] and
/// [selectedTool] stay with the live session when history is restored.
class CanvasHistorySnapshot {
  const CanvasHistorySnapshot({
    required this.gridRows,
    required this.gridColumns,
    required this.pixels,
  });

  final int gridRows;
  final int gridColumns;
  final List<List<Pixel>> pixels;

  /// Builds an independent copy of [state] suitable for the history stack.
  factory CanvasHistorySnapshot.fromState(CanvasState state) {
    return CanvasHistorySnapshot(
      gridRows: state.gridRows,
      gridColumns: state.gridColumns,
      pixels: _cloneMatrix(state.pixels),
    );
  }

  /// Merges this snapshot into [current], preserving tool and color choices.
  CanvasState applyTo(CanvasState current) {
    return CanvasState(
      gridRows: gridRows,
      gridColumns: gridColumns,
      activeColor: current.activeColor,
      selectedTool: current.selectedTool,
      pixels: _cloneMatrix(pixels),
    );
  }

  static List<List<Pixel>> _cloneMatrix(List<List<Pixel>> source) {
    return [
      for (final row in source)
        [for (final pixel in row) pixel],
    ];
  }
}

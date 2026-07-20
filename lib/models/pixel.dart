/// Represents a single cell on the motif grid.
///
/// [Pixel] is a value object: it stores position and color only, with no
/// knowledge of gestures, widgets, or rendering. Immutability ensures each
/// grid snapshot can be stored cheaply for a future undo/redo stack.
class Pixel {
  const Pixel({
    required this.row,
    required this.column,
    required this.color,
  });

  /// Zero-based row index within the grid.
  final int row;

  /// Zero-based column index within the grid.
  final int column;

  /// Current cell color encoded as 32-bit ARGB (`0xAARRGGBB`).
  ///
  /// Storing color as [int] keeps this model free of Flutter imports so it
  /// remains pure Dart and easy to unit test.
  final int color;

  /// ARGB value used for untouched / erased cells.
  static const int emptyColor = 0x00000000;

  /// Whether this cell has been painted with a visible color.
  bool get isFilled => color != emptyColor;

  /// Returns a copy of this pixel with selectively replaced fields.
  Pixel copyWith({
    int? row,
    int? column,
    int? color,
  }) {
    return Pixel(
      row: row ?? this.row,
      column: column ?? this.column,
      color: color ?? this.color,
    );
  }

  /// Creates an empty (unfilled) pixel at the given grid coordinates.
  factory Pixel.empty({required int row, required int column}) {
    return Pixel(row: row, column: column, color: emptyColor);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pixel &&
        other.row == row &&
        other.column == column &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(row, column, color);

  @override
  String toString() =>
      'Pixel(row: $row, column: $column, color: 0x${color.toRadixString(16).padLeft(8, '0')}, isFilled: $isFilled)';
}

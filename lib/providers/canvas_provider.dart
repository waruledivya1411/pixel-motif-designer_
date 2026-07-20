import 'package:flutter/foundation.dart';

import '../models/canvas_state.dart';
import '../models/drawing_tool.dart';
import '../models/pixel.dart';

/// Central state manager for the motif canvas.
///
/// [CanvasProvider] owns a single immutable [CanvasState] snapshot and exposes
/// intent-based methods (draw, erase, clear) so widgets stay presentation-only.
/// All mutation flows through [_commit], which guarantees listeners are
/// notified only when state actually changes.
class CanvasProvider extends ChangeNotifier {
  /// Creates a provider with an optional pre-built [initialState].
  CanvasProvider({CanvasState? initialState})
      : _state = initialState ?? CanvasState.initial();

  /// Current immutable canvas snapshot — the single source of truth.
  CanvasState _state;

  /// Read-only access to the full canvas snapshot.
  CanvasState get state => _state;

  /// Currently selected paint color (32-bit ARGB).
  int get activeColor => _state.activeColor;

  /// Active drawing tool (draw or erase).
  DrawingTool get selectedTool => _state.selectedTool;

  /// Pixel matrix indexed as [pixels][row][column].
  List<List<Pixel>> get pixels => _state.pixels;

  /// Number of grid rows.
  int get gridRows => _state.gridRows;

  /// Number of grid columns.
  int get gridColumns => _state.gridColumns;

  /// Updates the active paint color.
  ///
  /// Skips notification when the color is unchanged to avoid redundant
  /// widget rebuilds during rapid palette interactions.
  void changeActiveColor(int color) {
    if (_state.activeColor == color) return;
    _commit(_state.copyWith(activeColor: color));
  }

  /// Switches the active drawing tool.
  ///
  /// No-op when the requested tool is already selected.
  void changeDrawingTool(DrawingTool tool) {
    if (_state.selectedTool == tool) return;
    _commit(_state.copyWith(selectedTool: tool));
  }

  /// Paints [activeColor] onto the cell at [row], [column].
  ///
  /// Returns early when coordinates are invalid or the cell already holds
  /// [activeColor], preventing unnecessary matrix copies during drag drawing.
  void drawPixel(int row, int column) {
    final pixel = _state.pixelAt(row, column);
    if (pixel == null) return;
    if (pixel.color == _state.activeColor) return;

    final painted = pixel.copyWith(color: _state.activeColor);
    _commit(_state.withPixelAt(row, column, painted));
  }

  /// Clears the cell at [row], [column] back to empty.
  ///
  /// Returns early when coordinates are invalid or the cell is already empty,
  /// avoiding rebuilds as the user drags over blank cells in erase mode.
  void erasePixel(int row, int column) {
    final pixel = _state.pixelAt(row, column);
    if (pixel == null) return;
    if (!pixel.isFilled) return;

    _commit(
      _state.withPixelAt(
        row,
        column,
        Pixel.empty(row: row, column: column),
      ),
    );
  }

  /// Resets every cell to empty while preserving grid size, color, and tool.
  ///
  /// Skips notification when the canvas is already blank.
  void clearCanvas() {
    if (_state.filledPixelCount == 0) return;

    final emptyPixels = CanvasState.initial(
      gridRows: _state.gridRows,
      gridColumns: _state.gridColumns,
    ).pixels;

    _commit(_state.copyWith(pixels: emptyPixels));
  }

  /// Applies [newState] and notifies listeners only on a real change.
  ///
  /// Centralizing commits here is the performance gate: every public method
  /// funnels through this check so [notifyListeners] never fires for no-ops.
  void _commit(CanvasState newState) {
    if (newState == _state) return;
    _state = newState;
    notifyListeners();
  }
}

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
  /// Maximum number of undo steps retained in memory.
  static const int maxHistorySize = 30;

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

  /// Count of painted cells on the current canvas.
  ///
  /// Maintained incrementally in draw/erase/clear/resize handlers so widgets
  /// never scan the full pixel matrix on each rebuild.
  int get filledPixelCount => _filledPixelCount;

  /// Total cells in the grid ([gridRows] × [gridColumns]).
  int get totalPixelCount => _state.gridRows * _state.gridColumns;

  /// Whether an undo step is available.
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether a redo step is available.
  bool get canRedo => _redoStack.isNotEmpty;

  /// Running tally of filled pixels — updated O(1) per draw/erase/clear.
  late int _filledPixelCount;

  final List<CanvasHistorySnapshot> _undoStack = [];
  final List<CanvasHistorySnapshot> _redoStack = [];

  /// Canvas snapshot taken at the start of the current pointer stroke.
  CanvasHistorySnapshot? _strokeBaseline;

  /// Whether the active stroke changed any pixels.
  bool _strokeModified = false;

  /// Creates a provider with an optional pre-built [initialState].
  CanvasProvider({CanvasState? initialState})
      : _state = initialState ?? CanvasState.initial() {
    // Full-matrix scan runs once at startup, not on every frame.
    _filledPixelCount = _state.filledPixelCount;
  }

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

    final wasFilled = pixel.isFilled;
    final painted = pixel.copyWith(color: _state.activeColor);
    if (!wasFilled) _filledPixelCount++;
    _commitDuringStroke(_state.withPixelAt(row, column, painted));
  }

  /// Clears the cell at [row], [column] back to empty.
  ///
  /// Returns early when coordinates are invalid or the cell is already empty,
  /// avoiding rebuilds as the user drags over blank cells in erase mode.
  void erasePixel(int row, int column) {
    final pixel = _state.pixelAt(row, column);
    if (pixel == null) return;
    if (!pixel.isFilled) return;

    _filledPixelCount--;
    _commitDuringStroke(
      _state.withPixelAt(
        row,
        column,
        Pixel.empty(row: row, column: column),
      ),
    );
  }

  /// Applies the currently selected [selectedTool] to the cell at [row], [column].
  ///
  /// Single entry point for tap gestures — widgets forward coordinates only;
  /// tool selection and pixel mutation stay in this provider.
  void handlePixelTap(int row, int column) {
    _applyToolAt(row, column);
  }

  /// Last cell processed during the current drag stroke.
  ///
  /// Tracked separately from [CanvasState] because it is transient input state,
  /// not motif data — resetting it avoids redundant work when the finger
  /// hovers over the same pixel across multiple pointer-move events.
  int? _strokeRow;
  int? _strokeColumn;

  /// Marks the start of a pointer down / drag stroke.
  void beginStroke() {
    _strokeRow = null;
    _strokeColumn = null;
    _strokeModified = false;
    _strokeBaseline = CanvasHistorySnapshot.fromState(_state);
  }

  /// Marks the end of a pointer stroke and records one undo step when needed.
  void endStroke() {
    if (_strokeModified && _strokeBaseline != null) {
      _pushUndo(_strokeBaseline!);
      _redoStack.clear();
    }
    _strokeBaseline = null;
    _strokeModified = false;
    _strokeRow = null;
    _strokeColumn = null;
  }

  /// Applies the active tool during a continuous drag at [row], [column].
  ///
  /// Skips cells already handled in this stroke before delegating to
  /// [_applyToolAt], which applies its own pixel-level duplicate guards.
  void handlePixelDrag(int row, int column) {
    if (_strokeRow == row && _strokeColumn == column) return;
    _strokeRow = row;
    _strokeColumn = column;
    _applyToolAt(row, column);
  }

  /// Routes draw or erase for the active tool at the given coordinates.
  void _applyToolAt(int row, int column) {
    switch (_state.selectedTool) {
      case DrawingTool.draw:
        drawPixel(row, column);
      case DrawingTool.erase:
        erasePixel(row, column);
    }
  }

  /// Resets every cell to empty while preserving grid size, color, and tool.
  ///
  /// Skips notification when the canvas is already blank.
  void clearCanvas() {
    if (_filledPixelCount == 0) return;

    final emptyPixels = CanvasState.initial(
      gridRows: _state.gridRows,
      gridColumns: _state.gridColumns,
    ).pixels;

    _filledPixelCount = 0;
    _commitWithHistory(_state.copyWith(pixels: emptyPixels));
  }

  /// Rebuilds the canvas at [size] × [size] with a blank pixel matrix.
  ///
  /// Preserves [activeColor] and [selectedTool] so the user can keep
  /// painting immediately after resizing. No-op when [size] already matches
  /// the current square grid dimensions.
  void changeGridSize(int size) {
    if (_state.gridRows == size && _state.gridColumns == size) return;

    endStroke();

    _filledPixelCount = 0;
    _commitWithHistory(
      CanvasState.initial(
        gridRows: size,
        gridColumns: size,
        activeColor: _state.activeColor,
        selectedTool: _state.selectedTool,
      ),
    );
  }

  /// Replaces the canvas with [pixels] in a single commit.
  ///
  /// Used by template loading to apply a full motif at once instead of
  /// simulating hundreds of draw calls. Preserves the active color and tool.
  void loadTemplate({
    required List<List<Pixel>> pixels,
    required int gridSize,
  }) {
    endStroke();

    var filledCount = 0;
    for (final row in pixels) {
      for (final pixel in row) {
        if (pixel.isFilled) filledCount++;
      }
    }

    _filledPixelCount = filledCount;
    _commitWithHistory(
      CanvasState(
        gridRows: gridSize,
        gridColumns: gridSize,
        activeColor: _state.activeColor,
        selectedTool: _state.selectedTool,
        pixels: pixels,
      ),
    );
  }

  /// Restores the previous canvas snapshot from the undo stack.
  void undo() {
    if (_undoStack.isEmpty) return;

    endStroke();
    _redoStack.add(CanvasHistorySnapshot.fromState(_state));
    _restoreSnapshot(_undoStack.removeLast());
  }

  /// Re-applies a snapshot that was previously undone.
  void redo() {
    if (_redoStack.isEmpty) return;

    endStroke();
    _pushUndo(CanvasHistorySnapshot.fromState(_state));
    _restoreSnapshot(_redoStack.removeLast());
  }

  /// Persists [snapshot] on the undo stack and enforces [maxHistorySize].
  void _pushUndo(CanvasHistorySnapshot snapshot) {
    _undoStack.add(snapshot);
    if (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  void _restoreSnapshot(CanvasHistorySnapshot snapshot) {
    final restored = snapshot.applyTo(_state);
    if (restored == _state) return;
    _state = restored;
    _filledPixelCount = _state.filledPixelCount;
    notifyListeners();
  }

  /// Commits in-progress stroke pixels without creating a history entry.
  void _commitDuringStroke(CanvasState newState) {
    if (newState == _state) return;
    _strokeModified = true;
    _state = newState;
    notifyListeners();
  }

  /// Commits a discrete operation and records the pre-change canvas for undo.
  void _commitWithHistory(CanvasState newState) {
    if (newState == _state) return;
    _pushUndo(CanvasHistorySnapshot.fromState(_state));
    _redoStack.clear();
    _state = newState;
    notifyListeners();
  }

  /// Applies [newState] without touching undo/redo stacks.
  void _commit(CanvasState newState) {
    if (newState == _state) return;
    _state = newState;
    notifyListeners();
  }
}

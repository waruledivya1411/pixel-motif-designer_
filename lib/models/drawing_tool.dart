/// Identifies the active canvas interaction mode.
///
/// Keeping tools as an enum (rather than string flags) gives compile-time
/// safety and makes it straightforward to add new tools later — e.g.
/// [DrawingTool.fill] or [DrawingTool.pick] — without changing model shape.
enum DrawingTool {
  /// Paints the [CanvasState.activeColor] onto grid cells.
  draw,

  /// Clears grid cells back to the empty pixel color.
  erase,
}

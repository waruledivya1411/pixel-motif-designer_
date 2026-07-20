import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/color_constants.dart';
import '../core/constants/grid_constants.dart';
import '../providers/canvas_provider.dart';
import 'pixel_cell.dart';

/// Displays the full pixel motif grid driven by [CanvasProvider].
///
/// Grid dimensions and cell contents are read from provider state — nothing
/// is hardcoded. Each cell subscribes only to its own color via
/// [context.select], so updating one pixel rebuilds a single [PixelCell]
/// instead of the entire grid.
class PixelGrid extends StatelessWidget {
  const PixelGrid({
    this.cellSize = GridConstants.defaultCellSize,
    this.maxWidth,
    super.key,
  });

  /// Preferred edge length for every cell when space allows.
  final double cellSize;

  /// Maximum width available for the grid; used to scale cells on narrow screens.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    // Rebuild the grid scaffold only when row/column counts change.
    return Selector<CanvasProvider, ({int rows, int columns})>(
      selector: (_, provider) => (
        rows: provider.gridRows,
        columns: provider.gridColumns,
      ),
      shouldRebuild: (previous, next) =>
          previous.rows != next.rows || previous.columns != next.columns,
      builder: (context, dimensions, _) {
        final resolvedCellSize = _resolveCellSize(
          maxWidth: maxWidth,
          columns: dimensions.columns,
          preferred: cellSize,
        );

        return Semantics(
          label: 'Pixel canvas, ${dimensions.rows} by ${dimensions.columns}',
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: ColorConstants.gridLine),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .shadow
                        .withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadius - 1),
                child: _PixelGridGestureLayer(
                  key: ValueKey(
                    'pixel-grid-${dimensions.rows}x${dimensions.columns}',
                  ),
                  rows: dimensions.rows,
                  columns: dimensions.columns,
                  cellSize: resolvedCellSize,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      dimensions.rows,
                      (row) => _PixelGridRow(
                        row: row,
                        columnCount: dimensions.columns,
                        cellSize: resolvedCellSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Scales cell size down on narrow screens while preserving drawing coordinates.
double _resolveCellSize({
  required double? maxWidth,
  required int columns,
  required double preferred,
}) {
  if (maxWidth == null || maxWidth.isInfinite || maxWidth <= 0) {
    return preferred;
  }

  final fitted = maxWidth / columns;
  return fitted.clamp(
    GridConstants.minCellSize,
    preferred,
  );
}

/// Captures pointer events for tap and drag drawing across the entire grid.
///
/// A single grid-level [Listener] is used instead of per-cell gesture
/// detectors because:
/// - Pointer events fire immediately on down/move with no pan slop delay.
/// - One listener tracks continuous drags even when the finger moves quickly
///   between cells without lifting.
/// - Cells remain pure display widgets subscribed via [context.select].
class _PixelGridGestureLayer extends StatefulWidget {
  const _PixelGridGestureLayer({
    required this.rows,
    required this.columns,
    required this.cellSize,
    required this.child,
    super.key,
  });

  final int rows;
  final int columns;
  final double cellSize;
  final Widget child;

  @override
  State<_PixelGridGestureLayer> createState() => _PixelGridGestureLayerState();
}

class _PixelGridGestureLayerState extends State<_PixelGridGestureLayer> {
  /// Whether a pointer is currently pressed against the grid.
  bool _pointerActive = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerUp,
      child: widget.child,
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerActive = true;
    final provider = context.read<CanvasProvider>();
    provider.beginStroke();
    _forwardPointer(event.localPosition, provider);
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointerActive) return;
    _forwardPointer(event.localPosition, context.read<CanvasProvider>());
  }

  void _onPointerUp(PointerEvent event) {
    if (!_pointerActive) return;
    _pointerActive = false;
    context.read<CanvasProvider>().endStroke();
  }

  /// Converts a local pointer position to grid coordinates and forwards them.
  void _forwardPointer(Offset localPosition, CanvasProvider provider) {
    final coordinates = _cellCoordinatesFromOffset(
      localPosition,
      rows: widget.rows,
      columns: widget.columns,
      cellSize: widget.cellSize,
    );
    if (coordinates == null) return;

    provider.handlePixelDrag(coordinates.$1, coordinates.$2);
  }
}

/// Maps a local [offset] within the grid to zero-based (row, column) indices.
(int, int)? _cellCoordinatesFromOffset(
  Offset offset, {
  required int rows,
  required int columns,
  required double cellSize,
}) {
  final row = offset.dy ~/ cellSize;
  final column = offset.dx ~/ cellSize;

  if (row < 0 || row >= rows || column < 0 || column >= columns) {
    return null;
  }

  return (row, column);
}

/// One horizontal row of [_PixelCellAt] widgets.
///
/// Extracted so the outer [Column] stays readable; this row itself does not
/// listen to [CanvasProvider] — only its child cells do.
class _PixelGridRow extends StatelessWidget {
  const _PixelGridRow({
    required this.row,
    required this.columnCount,
    required this.cellSize,
  });

  final int row;
  final int columnCount;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        columnCount,
        (column) => _PixelCellAt(
          key: ValueKey('pixel-$row-$column'),
          row: row,
          column: column,
          cellSize: cellSize,
        ),
      ),
    );
  }
}

/// Provider-aware wrapper that rebuilds only when its cell color changes.
///
/// [RepaintBoundary] isolates each cell's paint pass so neighbouring cells
/// are not repainted during rapid drag drawing. Gesture handling lives on
/// [_PixelGridGestureLayer] so this widget never subscribes beyond its color.
class _PixelCellAt extends StatelessWidget {
  const _PixelCellAt({
    required this.row,
    required this.column,
    required this.cellSize,
    super.key,
  });

  final int row;
  final int column;
  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final color = context.select<CanvasProvider, int>(
      (provider) => provider.pixels[row][column].color,
    );

    return RepaintBoundary(
      child: PixelCell(
        color: color,
        size: cellSize,
      ),
    );
  }
}

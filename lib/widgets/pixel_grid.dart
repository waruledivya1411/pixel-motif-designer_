import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    super.key,
    this.cellSize = GridConstants.defaultCellSize,
  });

  /// Fixed edge length for every cell in the grid.
  final double cellSize;

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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            dimensions.rows,
            (row) => _PixelGridRow(
              row: row,
              columnCount: dimensions.columns,
              cellSize: cellSize,
            ),
          ),
        );
      },
    );
  }
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
/// are not repainted during rapid drag drawing in a later phase.
/// [GestureDetector] captures taps and delegates to [CanvasProvider.handlePixelTap]
/// without subscribing to the full provider — preserving fine-grained rebuilds.
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
      child: GestureDetector(
        // Forwards tap coordinates to the provider — no pixel logic in the widget.
        onTap: () => context.read<CanvasProvider>().handlePixelTap(row, column),
        child: PixelCell(
          color: color,
          size: cellSize,
        ),
      ),
    );
  }
}

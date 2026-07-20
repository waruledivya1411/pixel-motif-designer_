import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_motif_designer/core/constants/grid_constants.dart';
import 'package:pixel_motif_designer/models/canvas_state.dart';
import 'package:pixel_motif_designer/models/pixel.dart';
import 'package:pixel_motif_designer/services/svg_export_layout.dart';
import 'package:pixel_motif_designer/services/svg_generator.dart';
import 'package:xml/xml.dart';

void main() {
  const cellSize = GridConstants.exportCellPixelSize;

  group('SvgExportLayout', () {
    test('computes dimensions for every supported grid size', () {
      for (final gridSize in GridConstants.supportedGridSizes) {
        final layout = SvgExportLayout.fromCanvasState(
          CanvasState.initial(gridRows: gridSize, gridColumns: gridSize),
        );

        expect(layout.columns, gridSize);
        expect(layout.rows, gridSize);
        expect(layout.width, gridSize * cellSize);
        expect(layout.height, gridSize * cellSize);
        expect(layout.viewBox, '0 0 ${gridSize * cellSize} ${gridSize * cellSize}');
      }
    });

    test('maps grid coordinates to rect positions without offset', () {
      const gridSize = 16;
      final layout = SvgExportLayout.fromCanvasState(
        CanvasState.initial(gridRows: gridSize, gridColumns: gridSize),
      );

      final rect = layout.rectForCell(row: 3, column: 5);

      expect(rect.x, 5 * cellSize);
      expect(rect.y, 3 * cellSize);
      expect(rect.width, cellSize);
      expect(rect.height, cellSize);
    });
  });

  group('SvgGenerator', () {
    XmlElement parseRoot(String svg) {
      final document = XmlDocument.parse(svg);
      return document.rootElement;
    }

    Iterable<XmlElement> rects(XmlElement root) {
      return root.findElements('rect');
    }

    test('empty canvas exports full viewport with no rects', () {
      const gridSize = 16;
      final svg = SvgGenerator.generateFromCanvas(
        CanvasState.initial(gridRows: gridSize, gridColumns: gridSize),
      );
      final root = parseRoot(svg);

      expect(root.name.local, 'svg');
      expect(root.getAttribute('width'), '${gridSize * cellSize}px');
      expect(root.getAttribute('height'), '${gridSize * cellSize}px');
      expect(root.getAttribute('viewBox'), '0 0 ${gridSize * cellSize} ${gridSize * cellSize}');
      expect(rects(root), isEmpty);
    });

    test('exports correct viewport for 8x8, 16x16, and 32x32 grids', () {
      for (final gridSize in GridConstants.supportedGridSizes) {
        final svg = SvgGenerator.generateFromCanvas(
          CanvasState.initial(gridRows: gridSize, gridColumns: gridSize),
        );
        final root = parseRoot(svg);
        final expected = gridSize * cellSize;

        expect(root.getAttribute('width'), '${expected}px');
        expect(root.getAttribute('height'), '${expected}px');
        expect(root.getAttribute('viewBox'), '0 0 $expected $expected');
      }
    });

    test('single pixel is placed at exact grid coordinates', () {
      const gridSize = 16;
      final state = CanvasState.initial(
        gridRows: gridSize,
        gridColumns: gridSize,
      ).withPixelAt(
        2,
        4,
        Pixel(row: 2, column: 4, color: 0xFFE53935),
      );

      final root = parseRoot(SvgGenerator.generateFromCanvas(state));
      final rect = rects(root).single;

      expect(rect.getAttribute('x'), '${4 * cellSize}');
      expect(rect.getAttribute('y'), '${2 * cellSize}');
      expect(rect.getAttribute('width'), '$cellSize');
      expect(rect.getAttribute('height'), '$cellSize');
      expect(rect.getAttribute('fill'), '#e53935');
    });

    test('multiple colors and filled canvas preserve square pixels', () {
      const gridSize = 8;
      var state = CanvasState.initial(
        gridRows: gridSize,
        gridColumns: gridSize,
      );

      final colors = [0xFF000000, 0xFFE53935, 0xFF1E88E5, 0xFF43A047];

      for (var row = 0; row < gridSize; row++) {
        for (var column = 0; column < gridSize; column++) {
          final color = colors[(row + column) % colors.length];
          state = state.withPixelAt(
            row,
            column,
            Pixel(row: row, column: column, color: color),
          );
        }
      }

      final root = parseRoot(SvgGenerator.generateFromCanvas(state));
      final exportedRects = rects(root).toList();

      expect(exportedRects.length, gridSize * gridSize);

      for (final rect in exportedRects) {
        expect(rect.getAttribute('width'), rect.getAttribute('height'));
      }
    });

    test('unfilled cells are omitted to preserve transparency', () {
      const gridSize = 8;
      final state = CanvasState.initial(
        gridRows: gridSize,
        gridColumns: gridSize,
      ).withPixelAt(
        0,
        0,
        Pixel(row: 0, column: 0, color: 0xFF000000),
      );

      final root = parseRoot(SvgGenerator.generateFromCanvas(state));

      expect(rects(root).length, 1);
      expect(root.getAttribute('viewBox'), '0 0 ${gridSize * cellSize} ${gridSize * cellSize}');
    });
  });
}

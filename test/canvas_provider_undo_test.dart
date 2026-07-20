import 'package:flutter_test/flutter_test.dart';

import 'package:pixel_motif_designer/models/canvas_state.dart';
import 'package:pixel_motif_designer/models/drawing_tool.dart';
import 'package:pixel_motif_designer/providers/canvas_provider.dart';

void main() {
  group('CanvasProvider undo/redo', () {
    late CanvasProvider provider;

    setUp(() {
      provider = CanvasProvider();
    });

    test('single pixel stroke creates one undo step', () {
      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.endStroke();

      expect(provider.filledPixelCount, 1);
      expect(provider.canUndo, isTrue);
      expect(provider.canRedo, isFalse);

      provider.undo();
      expect(provider.filledPixelCount, 0);
      expect(provider.canRedo, isTrue);
    });

    test('drag stroke records one history entry for multiple pixels', () {
      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.drawPixel(0, 1);
      provider.drawPixel(0, 2);
      provider.endStroke();

      expect(provider.filledPixelCount, 3);

      provider.undo();
      expect(provider.filledPixelCount, 0);
    });

    test('eraser stroke is undoable', () {
      provider.beginStroke();
      provider.drawPixel(1, 1);
      provider.endStroke();

      provider.changeDrawingTool(DrawingTool.erase);
      provider.beginStroke();
      provider.erasePixel(1, 1);
      provider.endStroke();

      expect(provider.filledPixelCount, 0);

      provider.undo();
      expect(provider.filledPixelCount, 1);
    });

    test('clear canvas is undoable', () {
      provider.beginStroke();
      provider.drawPixel(2, 2);
      provider.endStroke();
      provider.clearCanvas();

      expect(provider.filledPixelCount, 0);

      provider.undo();
      expect(provider.filledPixelCount, 1);
    });

    test('template load is undoable', () {
      final base = CanvasState.initial(gridRows: 16, gridColumns: 16);
      final pixels = [
        for (var row = 0; row < 16; row++)
          [
            for (var column = 0; column < 16; column++)
              base.pixels[row][column],
          ],
      ];
      pixels[0][0] = pixels[0][0].copyWith(color: 0xFFE53935);

      provider.loadTemplate(pixels: pixels, gridSize: 16);

      expect(provider.filledPixelCount, 1);

      provider.undo();
      expect(provider.filledPixelCount, 0);
    });

    test('grid resize is undoable', () {
      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.endStroke();
      provider.changeGridSize(32);

      expect(provider.gridRows, 32);
      expect(provider.filledPixelCount, 0);

      provider.undo();
      expect(provider.gridRows, 16);
      expect(provider.filledPixelCount, 1);
    });

    test('redo restores undone state', () {
      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.endStroke();

      provider.undo();
      expect(provider.filledPixelCount, 0);

      provider.redo();
      expect(provider.filledPixelCount, 1);
    });

    test('new drawing clears redo stack', () {
      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.endStroke();

      provider.undo();
      expect(provider.canRedo, isTrue);

      provider.beginStroke();
      provider.drawPixel(1, 1);
      provider.endStroke();

      expect(provider.canRedo, isFalse);
    });

    test('history is capped at maxHistorySize', () {
      for (var i = 0; i < CanvasProvider.maxHistorySize + 5; i++) {
        provider.beginStroke();
        provider.drawPixel(
          i ~/ provider.gridColumns,
          i % provider.gridColumns,
        );
        provider.endStroke();
      }

      var undoCount = 0;
      while (provider.canUndo) {
        provider.undo();
        undoCount++;
      }

      expect(undoCount, CanvasProvider.maxHistorySize);
    });

    test('undo and redo preserve active color and tool', () {
      provider.changeActiveColor(0xFFE53935);
      provider.changeDrawingTool(DrawingTool.erase);

      provider.beginStroke();
      provider.drawPixel(0, 0);
      provider.endStroke();

      provider.undo();
      provider.redo();

      expect(provider.activeColor, 0xFFE53935);
      expect(provider.selectedTool, DrawingTool.erase);
    });
  });
}

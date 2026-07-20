import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_motif_designer/core/constants/grid_constants.dart';
import 'package:pixel_motif_designer/models/pixel_template.dart';
import 'package:pixel_motif_designer/services/template_service.dart';

void main() {
  group('TemplateService', () {
    test('exposes six built-in templates', () {
      expect(TemplateService.templates.length, 6);
      expect(
        TemplateService.templates.map((template) => template.id),
        containsAll(['heart', 'star', 'smile', 'flower', 'moon', 'mushroom']),
      );
    });

    test('builds a 16x16 matrix with filled pixels', () {
      final template = TemplateService.templates.first;
      final matrix = TemplateService.buildPixelMatrix(
        template: template,
        targetGridSize: 16,
      );

      expect(matrix.length, 16);
      expect(matrix.first.length, 16);

      var filled = 0;
      for (final row in matrix) {
        for (final pixel in row) {
          if (pixel.isFilled) filled++;
        }
      }

      expect(filled, template.pixels.length);
    });

    test('scales templates onto a 32x32 canvas', () {
      final template = TemplateService.templates.firstWhere(
        (item) => item.id == 'heart',
      );
      final matrix = TemplateService.buildPixelMatrix(
        template: template,
        targetGridSize: 32,
      );

      var filled = 0;
      for (final row in matrix) {
        for (final pixel in row) {
          if (pixel.isFilled) filled++;
        }
      }

      expect(filled, template.pixels.length * 4);
    });

    test('flags resize when the canvas is too small', () {
      const largeTemplate = PixelTemplate(
        id: 'large',
        name: 'Large',
        emoji: '🧪',
        designGridSize: 32,
        minGridSize: 32,
        supportedGridSizes: GridConstants.supportedGridSizes,
        pixels: [TemplatePixel(row: 0, column: 0, color: 0xFFE53935)],
      );

      final plan = TemplateService.planFor(
        template: largeTemplate,
        currentGridSize: 16,
      );

      expect(plan.requiresResize, isTrue);
      expect(plan.targetGridSize, 32);
    });
  });
}

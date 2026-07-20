import '../core/constants/grid_constants.dart';
import '../models/pixel.dart';
import '../models/pixel_template.dart';

/// Result of preparing a template for a specific canvas size.
class TemplateLoadPlan {
  const TemplateLoadPlan({
    required this.targetGridSize,
    required this.pixels,
    this.requiresResize = false,
  });

  /// Whether the canvas must grow before the template can load.
  final bool requiresResize;

  /// Grid edge length the canvas should use when loading.
  final int targetGridSize;

  /// Full pixel matrix ready for [CanvasProvider.loadTemplate].
  final List<List<Pixel>> pixels;
}

/// Catalog and scaling logic for built-in pixel templates.
///
/// Keeps template data and grid math out of widgets and providers so new
/// motifs can be added by extending the catalog only.
abstract final class TemplateService {
  static const int _red = 0xFFE53935;
  static const int _yellow = 0xFFFDD835;
  static const int _green = 0xFF43A047;
  static const int _blue = 0xFF1E88E5;
  static const int _black = 0xFF000000;
  static const int _white = 0xFFFFFFFF;

  /// All built-in templates available in the picker screen.
  static List<PixelTemplate> get templates => _catalog;

  static final List<PixelTemplate> _catalog = [
    PixelTemplate(
      id: 'heart',
      name: 'Heart',
      emoji: '❤️',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
..RR..RR..
.RRRRRRRR.
.RRRRRRRR.
..RRRRRR..
...RRRR...
....RR....
.....R....
''',
        offsetRow: 4,
        offsetColumn: 3,
      ),
    ),
    PixelTemplate(
      id: 'star',
      name: 'Star',
      emoji: '⭐',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
....Y....
...YYY...
..YYYYY..
.YYYYYYY.
..YYYYY..
...YYY...
....Y....
....Y....
''',
        offsetRow: 3,
        offsetColumn: 4,
      ),
    ),
    PixelTemplate(
      id: 'smile',
      name: 'Smile',
      emoji: '😊',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
..YYYYYY..
.YYYYYYYY.
YBBYYYYBBY
YYYYYYYYYY
YBYYYYYBYY
YYBYYYBYY.
.YYBBBYY..
..YYYYY...
''',
        offsetRow: 3,
        offsetColumn: 2,
      ),
    ),
    PixelTemplate(
      id: 'flower',
      name: 'Flower',
      emoji: '🌸',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
....YY....
...RRRR...
..RRRRRR..
...RRRR...
....GG....
....GG....
...GGGG...
....GG....
''',
        offsetRow: 3,
        offsetColumn: 4,
      ),
    ),
    PixelTemplate(
      id: 'moon',
      name: 'Moon',
      emoji: '🌙',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
....YYYY..
...YYYYY..
..YYYYY...
..YYYY....
..YYY.....
..YY......
...Y......
''',
        offsetRow: 4,
        offsetColumn: 4,
      ),
    ),
    PixelTemplate(
      id: 'mushroom',
      name: 'Mushroom',
      emoji: '🍄',
      designGridSize: 16,
      minGridSize: 16,
      supportedGridSizes: GridConstants.supportedGridSizes,
      pixels: _pattern(
        '''
....RRRR...
...RWRWR...
..RRRRRRR.
...WWWWW...
....WWW....
....WWW....
....WWW....
....WWW....
''',
        offsetRow: 3,
        offsetColumn: 3,
      ),
    ),
  ];

  /// Returns the smallest supported grid size when [currentGridSize] is too small.
  static int? suggestedGridSize(PixelTemplate template, int currentGridSize) {
    if (currentGridSize >= template.minGridSize) return null;

    for (final size in GridConstants.supportedGridSizes) {
      if (size >= template.minGridSize) return size;
    }

    return template.minGridSize;
  }

  /// Builds a load plan for [template] on [currentGridSize].
  ///
  /// When the canvas is too small, [TemplateLoadPlan.requiresResize] is true
  /// and [targetGridSize] is the recommended larger grid.
  static TemplateLoadPlan planFor({
    required PixelTemplate template,
    required int currentGridSize,
    int? overrideGridSize,
  }) {
    final targetGridSize = overrideGridSize ?? currentGridSize;
    final requiresResize =
        overrideGridSize == null && currentGridSize < template.minGridSize;

    return TemplateLoadPlan(
      requiresResize: requiresResize,
      targetGridSize: requiresResize
          ? (suggestedGridSize(template, currentGridSize) ?? template.minGridSize)
          : targetGridSize,
      pixels: buildPixelMatrix(
        template: template,
        targetGridSize: requiresResize
            ? (suggestedGridSize(template, currentGridSize) ??
                template.minGridSize)
            : targetGridSize,
      ),
    );
  }

  /// Maps template pixels onto a square [targetGridSize] matrix in one pass.
  static List<List<Pixel>> buildPixelMatrix({
    required PixelTemplate template,
    required int targetGridSize,
  }) {
    final matrix = List.generate(
      targetGridSize,
      (row) => List.generate(
        targetGridSize,
        (column) => Pixel.empty(row: row, column: column),
      ),
    );

    final scale = targetGridSize ~/ template.designGridSize;
    final offset = (targetGridSize - template.designGridSize * scale) ~/ 2;

    for (final templatePixel in template.pixels) {
      if (scale == 1) {
        final row = templatePixel.row + offset;
        final column = templatePixel.column + offset;
        if (_isInBounds(row, column, targetGridSize)) {
          matrix[row][column] = Pixel(
            row: row,
            column: column,
            color: templatePixel.color,
          );
        }
        continue;
      }

      for (var rowDelta = 0; rowDelta < scale; rowDelta++) {
        for (var columnDelta = 0; columnDelta < scale; columnDelta++) {
          final row = templatePixel.row * scale + rowDelta + offset;
          final column = templatePixel.column * scale + columnDelta + offset;
          if (!_isInBounds(row, column, targetGridSize)) continue;

          matrix[row][column] = Pixel(
            row: row,
            column: column,
            color: templatePixel.color,
          );
        }
      }
    }

    return matrix;
  }

  static bool _isInBounds(int row, int column, int gridSize) {
    return row >= 0 &&
        column >= 0 &&
        row < gridSize &&
        column < gridSize;
  }

  /// Parses an ASCII art [pattern] into sparse [TemplatePixel] entries.
  static List<TemplatePixel> _pattern(
    String pattern, {
    required int offsetRow,
    required int offsetColumn,
  }) {
    const colorMap = {
      'R': _red,
      'Y': _yellow,
      'G': _green,
      'U': _blue,
      'B': _black,
      'W': _white,
    };

    final pixels = <TemplatePixel>[];
    final lines = pattern.trim().split('\n');

    for (var row = 0; row < lines.length; row++) {
      final line = lines[row];
      for (var column = 0; column < line.length; column++) {
        final color = colorMap[line[column]];
        if (color == null) continue;

        pixels.add(
          TemplatePixel(
            row: offsetRow + row,
            column: offsetColumn + column,
            color: color,
          ),
        );
      }
    }

    return pixels;
  }
}

import 'package:xml/xml.dart';

import '../models/canvas_state.dart';

/// Generates valid SVG documents from motif [CanvasState] snapshots.
///
/// Kept separate from [ExportService] so SVG encoding can be unit-tested
/// without platform I/O and reused by future import/export features.
abstract final class SvgGenerator {
  /// Builds an SVG string where each filled pixel becomes a `<rect>`.
  ///
  /// The root `<svg>` width and height match [CanvasState.gridColumns] and
  /// [CanvasState.gridRows]. Empty pixels are omitted to keep files compact.
  static String generateFromCanvas(CanvasState state) {
    final width = state.gridColumns;
    final height = state.gridRows;

    final builder = XmlBuilder();

    builder.element(
      'svg',
      attributes: {
        'xmlns': 'http://www.w3.org/2000/svg',
        'width': '$width',
        'height': '$height',
        'viewBox': '0 0 $width $height',
      },
      nest: () {
        for (var row = 0; row < state.gridRows; row++) {
          for (var column = 0; column < state.gridColumns; column++) {
            final pixel = state.pixels[row][column];
            if (!pixel.isFilled) continue;

            builder.element(
              'rect',
              attributes: {
                'x': '$column',
                'y': '$row',
                'width': '1',
                'height': '1',
                'fill': _argbToHex(pixel.color),
              },
            );
          }
        }
      },
    );

    return builder.buildDocument().toXmlString(pretty: true);
  }

  /// Converts a 32-bit ARGB value to an SVG `#RRGGBB` hex color string.
  static String _argbToHex(int argb) {
    final red = (argb >> 16) & 0xFF;
    final green = (argb >> 8) & 0xFF;
    final blue = argb & 0xFF;

    return '#'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}

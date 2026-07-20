import 'package:xml/xml.dart';

import '../models/canvas_state.dart';
import 'svg_export_layout.dart';

/// Generates valid SVG documents from motif [CanvasState] snapshots.
///
/// Kept separate from [ExportService] so SVG encoding can be unit-tested
/// without platform I/O and reused by future import/export features.
abstract final class SvgGenerator {
  /// Builds an SVG string where each filled pixel becomes a `<rect>`.
  ///
  /// The root `<svg>` viewport is sized to the full grid canvas via
  /// [SvgExportLayout] — width, height, viewBox, and rect coordinates all
  /// derive from the same layout so viewers never letterbox the artwork.
  static String generateFromCanvas(CanvasState state) {
    final layout = SvgExportLayout.fromCanvasState(state);
    final builder = XmlBuilder();

    builder.element(
      'svg',
      attributes: {
        'xmlns': 'http://www.w3.org/2000/svg',
        'width': layout.widthAttribute,
        'height': layout.heightAttribute,
        'viewBox': layout.viewBox,
        'shape-rendering': 'crispEdges',
      },
      nest: () {
        for (var row = 0; row < state.gridRows; row++) {
          for (var column = 0; column < state.gridColumns; column++) {
            final pixel = state.pixels[row][column];
            if (!pixel.isFilled) continue;

            final rect = layout.rectForCell(row: row, column: column);

            builder.element(
              'rect',
              attributes: {
                'x': '${rect.x}',
                'y': '${rect.y}',
                'width': '${rect.width}',
                'height': '${rect.height}',
                'fill': _argbToSvgColor(pixel.color),
              },
            );
          }
        }
      },
    );

    return builder.buildDocument().toXmlString();
  }

  /// Converts a 32-bit ARGB value to an SVG color string.
  ///
  /// Includes alpha when the pixel is translucent so transparency matches
  /// the canvas model. Opaque colors use the shorter `#RRGGBB` form.
  static String _argbToSvgColor(int argb) {
    final alpha = (argb >> 24) & 0xFF;
    final red = (argb >> 16) & 0xFF;
    final green = (argb >> 8) & 0xFF;
    final blue = argb & 0xFF;

    final redHex = red.toRadixString(16).padLeft(2, '0');
    final greenHex = green.toRadixString(16).padLeft(2, '0');
    final blueHex = blue.toRadixString(16).padLeft(2, '0');

    if (alpha < 255) {
      final alphaHex = alpha.toRadixString(16).padLeft(2, '0');
      return '#$redHex$greenHex$blueHex$alphaHex';
    }

    return '#$redHex$greenHex$blueHex';
  }
}

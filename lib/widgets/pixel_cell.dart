import 'package:flutter/material.dart';

import '../core/constants/color_constants.dart';
import '../models/pixel.dart';

/// A single square cell in the motif grid.
///
/// [PixelCell] is a pure presentation widget — it receives color and size via
/// constructor parameters with no provider dependency, making it reusable in
/// previews, tests, and export thumbnails.
class PixelCell extends StatelessWidget {
  const PixelCell({
    required this.color,
    required this.size,
    super.key,
  });

  /// Cell color encoded as 32-bit ARGB (`0xAARRGGBB`).
  final int color;

  /// Fixed width and height of the cell in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _displayColor,
          border: Border.all(
            color: ColorConstants.gridLine,
            width: 0.5,
          ),
        ),
      ),
    );
  }

  /// Maps the raw ARGB value to a visible [Color].
  ///
  /// Empty (transparent) pixels render as the canvas background so grid
  /// structure remains visible before any drawing occurs.
  Color get _displayColor {
    if (color == Pixel.emptyColor) {
      return ColorConstants.canvasBackground;
    }
    return Color(color);
  }
}

import 'package:flutter/material.dart';

/// Default color palette for motif design.
///
/// These are the initial swatch colors users can pick from before
/// custom color support is added.
abstract final class ColorConstants {
  /// Canvas background — neutral so colored pixels stand out.
  static const Color canvasBackground = Color(0xFFF5F5F5);

  /// Grid line color drawn over the canvas.
  static const Color gridLine = Color(0xFFE0E0E0);

  /// Default motif pixel colors available in the palette.
  static const List<Color> defaultPalette = [
    Color(0xFF000000), // Black
    Color(0xFFFFFFFF), // White
    Color(0xFFE53935), // Red
    Color(0xFF43A047), // Green
    Color(0xFF1E88E5), // Blue
    Color(0xFFFDD835), // Yellow
    Color(0xFF8E24AA), // Purple
    Color(0xFFFB8C00), // Orange
  ];

  /// Primary swatches displayed in the drawing color palette.
  static const List<Color> drawingPalette = [
    Color(0xFF000000), // Black
    Color(0xFFE53935), // Red
    Color(0xFF1E88E5), // Blue
    Color(0xFF43A047), // Green
    Color(0xFFFDD835), // Yellow
  ];

  /// Fallback color when no pixel has been painted yet.
  static const Color emptyCell = Color(0x00000000);
}

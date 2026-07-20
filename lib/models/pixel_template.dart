/// A single painted cell inside a [PixelTemplate] design.
///
/// Coordinates are zero-based within the template's [PixelTemplate.designGridSize].
class TemplatePixel {
  const TemplatePixel({
    required this.row,
    required this.column,
    required this.color,
  });

  final int row;
  final int column;

  /// 32-bit ARGB color (`0xAARRGGBB`).
  final int color;
}

/// Declarative pixel-art motif that can be scaled onto the live canvas.
///
/// Templates store sparse pixel coordinates at a native [designGridSize].
/// [TemplateService] maps them onto 16×16 or 32×32 grids without widgets
/// knowing placement rules.
class PixelTemplate {
  const PixelTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.designGridSize,
    required this.minGridSize,
    required this.supportedGridSizes,
    required this.pixels,
  });

  /// Stable identifier for routing and tests.
  final String id;

  /// Display name shown on template cards.
  final String name;

  /// Decorative emoji for quick visual recognition.
  final String emoji;

  /// Native grid dimension the [pixels] were authored against.
  final int designGridSize;

  /// Smallest canvas edge length required to display this template.
  final int minGridSize;

  /// Grid sizes this template supports without forcing a resize prompt.
  final List<int> supportedGridSizes;

  /// Sparse pixel coordinates and colors for the native design grid.
  final List<TemplatePixel> pixels;
}

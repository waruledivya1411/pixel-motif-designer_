import 'package:flutter/material.dart';

import '../core/constants/color_constants.dart';
import '../models/pixel_template.dart';

/// Renders a small pixel-accurate preview of a [PixelTemplate].
class TemplatePreview extends StatelessWidget {
  const TemplatePreview({
    required this.template,
    this.size = 72,
    super.key,
  });

  final PixelTemplate template;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cellSize = size / template.designGridSize;
    final pixelLookup = {
      for (final pixel in template.pixels)
        (pixel.row, pixel.column): pixel.color,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ColorConstants.canvasBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorConstants.gridLine),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(template.designGridSize, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(template.designGridSize, (column) {
                  final color = pixelLookup[(row, column)];
                  return Container(
                    width: cellSize,
                    height: cellSize,
                    color: color == null
                        ? ColorConstants.canvasBackground
                        : Color(color),
                  );
                }),
              );
            }),
          ),
        ),
      ),
    );
  }
}

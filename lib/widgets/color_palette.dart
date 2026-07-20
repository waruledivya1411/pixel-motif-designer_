import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/color_constants.dart';
import '../providers/canvas_provider.dart';

/// Horizontal row of selectable paint swatches for the motif canvas.
///
/// Each swatch delegates color changes to [CanvasProvider.changeActiveColor]
/// and subscribes only to its own selected state — the palette container
/// itself does not rebuild when the active color changes.
class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppConstants.paddingMedium,
        runSpacing: AppConstants.paddingSmall,
        children: [
          for (final color in ColorConstants.drawingPalette)
            _ColorSwatch(color: color),
        ],
      ),
    );
  }
}

/// A single circular color swatch with Material 3 selection styling.
///
/// Uses [context.select] so only the previously selected swatch and the
/// newly selected swatch rebuild when [CanvasProvider.activeColor] changes.
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color});

  final Color color;

  static const double _swatchSize = 44;

  @override
  Widget build(BuildContext context) {
    final argb = color.toARGB32();
    final isSelected = context.select<CanvasProvider, bool>(
      (provider) => provider.activeColor == argb,
    );

    final theme = Theme.of(context);
    final checkColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Semantics(
      label: 'Select color',
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () =>
              context.read<CanvasProvider>().changeActiveColor(argb),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: _swatchSize,
            height: _swatchSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : ColorConstants.gridLine,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    color: checkColor,
                    size: 22,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

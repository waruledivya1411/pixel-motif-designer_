import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/color_constants.dart';
import '../providers/canvas_provider.dart';
import '../providers/palette_provider.dart';
import 'custom_color_picker_sheet.dart';

/// Horizontal row of selectable paint swatches for the motif canvas.
///
/// Preset swatches delegate to [CanvasProvider.changeActiveColor]; the custom
/// swatch opens an HSV picker and stores its value in [PaletteProvider].
class ColorPalette extends StatelessWidget {
  const ColorPalette({super.key});

  static const double _swatchSize = 36;
  static const double _swatchSpacing = AppConstants.paddingSmall;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Color palette',
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < ColorConstants.drawingPalette.length; i++) ...[
              if (i > 0) const SizedBox(width: _swatchSpacing),
              _ColorSwatch(
                color: ColorConstants.drawingPalette[i],
                slotIndex: i,
                size: _swatchSize,
              ),
            ],
            const SizedBox(width: _swatchSpacing),
            const _CustomColorSwatch(size: _swatchSize),
          ],
        ),
      ),
    );
  }
}

/// Human-readable names for palette swatches used in tooltips and semantics.
String _colorName(Color color) {
  return switch (color.toARGB32()) {
    0xFF000000 => 'Black',
    0xFFE53935 => 'Red',
    0xFF1E88E5 => 'Blue',
    0xFF43A047 => 'Green',
    0xFFFDD835 => 'Yellow',
    _ => 'Color',
  };
}

/// A single circular color swatch with Material 3 selection styling.
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.slotIndex,
    required this.size,
  });

  final Color color;
  final int slotIndex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final argb = color.toARGB32();
    final isSelected = context.select<PaletteProvider, bool>(
      (provider) => provider.selectedSlot == slotIndex,
    );

    final theme = Theme.of(context);
    final colorLabel = _colorName(color);
    final checkColor = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Tooltip(
      message: isSelected ? '$colorLabel (selected)' : 'Select $colorLabel',
      child: Semantics(
        label: colorLabel,
        hint: 'Paint color',
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              context.read<PaletteProvider>().selectPreset(slotIndex);
              context.read<CanvasProvider>().changeActiveColor(argb);
            },
            child: SizedBox(
              width: AppConstants.minTouchTarget,
              height: AppConstants.minTouchTarget,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : ColorConstants.gridLine,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: checkColor,
                          size: size * 0.55,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom color swatch placed after Yellow — opens the HSV color picker.
class _CustomColorSwatch extends StatelessWidget {
  const _CustomColorSwatch({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.select<PaletteProvider, ({int color, bool selected})>(
      (provider) => (
        color: provider.customColor,
        selected: provider.isCustomSelected,
      ),
    );

    final theme = Theme.of(context);
    final customColor = Color(palette.color);
    final isSelected = palette.selected;
    final checkColor = customColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Tooltip(
      message: isSelected
          ? 'Custom color (selected)'
          : 'Pick a custom color',
      child: Semantics(
        label: 'Custom color',
        hint: 'Opens color picker',
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _openPicker(context, customColor),
            child: SizedBox(
              width: AppConstants.minTouchTarget,
              height: AppConstants.minTouchTarget,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: size,
                  height: size,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFFFF0000),
                        Color(0xFFFFFF00),
                        Color(0xFF00FF00),
                        Color(0xFF00FFFF),
                        Color(0xFF0000FF),
                        Color(0xFFFF00FF),
                        Color(0xFFFF0000),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ]
                        : null,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: customColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: checkColor,
                            size: size * 0.5,
                          )
                        : Center(
                            child: Icon(
                              Icons.colorize_rounded,
                              size: size * 0.45,
                              color: checkColor.withValues(alpha: 0.9),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context, Color initialColor) async {
    final picked = await showCustomColorPickerSheet(
      context,
      initialColor: initialColor,
    );
    if (picked == null || !context.mounted) return;

    final argb = picked.toARGB32();
    context.read<PaletteProvider>().setCustomColor(argb);
    context.read<CanvasProvider>().changeActiveColor(argb);
  }
}

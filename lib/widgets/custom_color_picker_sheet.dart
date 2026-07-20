import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Material 3 bottom sheet for picking any paint color via HSV sliders.
Future<Color?> showCustomColorPickerSheet(
  BuildContext context, {
  required Color initialColor,
}) {
  return showModalBottomSheet<Color>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CustomColorPickerSheet(initialColor: initialColor),
  );
}

class _CustomColorPickerSheet extends StatefulWidget {
  const _CustomColorPickerSheet({required this.initialColor});

  final Color initialColor;

  @override
  State<_CustomColorPickerSheet> createState() => _CustomColorPickerSheetState();
}

class _CustomColorPickerSheetState extends State<_CustomColorPickerSheet> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  Color get _currentColor => _hsv.toColor();

  String get _hexLabel {
    final value = _currentColor.toARGB32();
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Custom Color',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _currentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            _hexLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          _SliderRow(
            label: 'Hue',
            value: _hsv.hue,
            min: 0,
            max: 360,
            activeColor: HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
            onChanged: (value) {
              setState(() => _hsv = _hsv.withHue(value));
            },
          ),
          _SliderRow(
            label: 'Saturation',
            value: _hsv.saturation,
            min: 0,
            max: 1,
            activeColor: _currentColor,
            onChanged: (value) {
              setState(() => _hsv = _hsv.withSaturation(value));
            },
          ),
          _SliderRow(
            label: 'Brightness',
            value: _hsv.value,
            min: 0,
            max: 1,
            activeColor: _currentColor,
            onChanged: (value) {
              setState(() => _hsv = _hsv.withValue(value));
            },
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_currentColor),
            child: const Text('Use Color'),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              thumbColor: activeColor,
              overlayColor: activeColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

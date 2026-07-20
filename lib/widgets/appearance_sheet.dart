import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/theme_provider.dart';

/// Material 3 bottom sheet for choosing light, dark, or system appearance.
Future<void> showAppearanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => const _AppearanceSheet(),
  );
}

class _AppearanceSheet extends StatelessWidget {
  const _AppearanceSheet();

  static const _options = <_AppearanceOption>[
    _AppearanceOption(
      mode: ThemeMode.light,
      emoji: '☀️',
      label: 'Light Mode',
    ),
    _AppearanceOption(
      mode: ThemeMode.dark,
      emoji: '🌙',
      label: 'Dark Mode',
    ),
    _AppearanceOption(
      mode: ThemeMode.system,
      emoji: '📱',
      label: 'System Default',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMode = context.select<ThemeProvider, ThemeMode>(
      (provider) => provider.themeMode,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
        AppConstants.paddingMedium,
        AppConstants.paddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Appearance',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          RadioGroup<ThemeMode>(
            groupValue: selectedMode,
            onChanged: (mode) async {
              if (mode == null) {
                return;
              }
              await context.read<ThemeProvider>().setThemeMode(mode);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                for (final option in _options)
                  _AppearanceOptionTile(
                    option: option,
                    isSelected: option.mode == selectedMode,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOption {
  const _AppearanceOption({
    required this.mode,
    required this.emoji,
    required this.label,
  });

  final ThemeMode mode;
  final String emoji;
  final String label;
}

class _AppearanceOptionTile extends StatelessWidget {
  const _AppearanceOptionTile({
    required this.option,
    required this.isSelected,
  });

  final _AppearanceOption option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.55)
            : theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: RadioListTile<ThemeMode>(
          value: option.mode,
          title: Text('${option.emoji} ${option.label}'),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
        ),
      ),
    );
  }
}

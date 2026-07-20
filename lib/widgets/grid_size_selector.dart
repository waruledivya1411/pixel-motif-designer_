import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/grid_constants.dart';
import '../providers/canvas_provider.dart';

/// Drawer control for choosing a square canvas dimension.
///
/// Delegates confirmed size changes to [CanvasProvider.changeGridSize] after
/// warning the user that the current motif will be cleared. Styled as a card
/// panel to match [EditorPanel] and the main editor UI.
class GridSizeSelector extends StatelessWidget {
  const GridSizeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedSize = context.select<CanvasProvider, int>(
      (provider) => provider.gridRows,
    );

    final theme = Theme.of(context);

    return Semantics(
      label: 'Grid size selector',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.85),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.aspect_ratio_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      'Grid size',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Select the canvas resolution for your motif.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              for (var i = 0; i < GridConstants.supportedGridSizes.length; i++) ...[
                if (i > 0) const SizedBox(height: AppConstants.paddingSmall),
                _GridSizeOption(
                  size: GridConstants.supportedGridSizes[i],
                  selectedSize: selectedSize,
                  subtitle: _subtitleForSize(
                    GridConstants.supportedGridSizes[i],
                  ),
                  onSelected: (newSize) =>
                      _confirmGridSizeChange(context, newSize),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _subtitleForSize(int size) {
    final total = size * size;
    final label = switch (size) {
      16 => 'Standard',
      32 => 'Large',
      _ => 'Custom',
    };
    return '$label · $total pixels';
  }

  /// Shows a confirmation dialog before applying a destructive grid resize.
  Future<void> _confirmGridSizeChange(
    BuildContext context,
    int newSize,
  ) async {
    final canvasProvider = context.read<CanvasProvider>();
    if (newSize == canvasProvider.gridRows) return;

    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change grid size'),
          content: const Text(
            'Changing the grid size will clear the current canvas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true || !context.mounted) return;

    canvasProvider.changeGridSize(newSize);

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }
}

/// A single grid dimension option styled like the editor tool buttons.
class _GridSizeOption extends StatelessWidget {
  const _GridSizeOption({
    required this.size,
    required this.selectedSize,
    required this.subtitle,
    required this.onSelected,
  });

  final int size;
  final int selectedSize;
  final String subtitle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = size == selectedSize;
    final titleColor = theme.colorScheme.onSurface;
    final subtitleColor = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: '$size by $size grid',
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          onTap: () => onSelected(size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.75),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                _GridPreviewIcon(size: size, isSelected: isSelected),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$size × $size',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tiny grid glyph hinting at the relative density of each canvas size.
class _GridPreviewIcon extends StatelessWidget {
  const _GridPreviewIcon({
    required this.size,
    required this.isSelected,
  });

  final int size;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellCount = switch (size) {
      16 => 4,
      32 => 5,
      _ => 4,
    };

    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.35)
              : theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cellCount,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        children: List.generate(
          cellCount * cellCount,
          (_) => DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}

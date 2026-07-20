import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/constants/grid_constants.dart';
import '../providers/canvas_provider.dart';

/// Drawer-friendly control for choosing a square canvas dimension.
///
/// Delegates confirmed size changes to [CanvasProvider.changeGridSize] after
/// warning the user that the current motif will be cleared. Uses [Radio]
/// tiles instead of [SegmentedButton] so async confirmation dialogs do not
/// desynchronize button selection state (which caused crashes on size change).
class GridSizeSelector extends StatelessWidget {
  const GridSizeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedSize = context.select<CanvasProvider, int>(
      (provider) => provider.gridRows,
    );

    return Semantics(
      label: 'Grid size selector',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingMedium,
              AppConstants.paddingSmall,
              AppConstants.paddingMedium,
              0,
            ),
            child: Text(
              'Grid size',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final size in GridConstants.supportedGridSizes)
            _GridSizeTile(
              size: size,
              selectedSize: selectedSize,
              onSelected: (newSize) => _confirmGridSizeChange(context, newSize),
            ),
        ],
      ),
    );
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

/// A single selectable grid dimension row inside the navigation drawer.
class _GridSizeTile extends StatelessWidget {
  const _GridSizeTile({
    required this.size,
    required this.selectedSize,
    required this.onSelected,
  });

  final int size;
  final int selectedSize;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = '$size × $size';
    final isSelected = size == selectedSize;

    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(label),
      selected: isSelected,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      onTap: () => onSelected(size),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../models/drawing_tool.dart';
import '../providers/canvas_provider.dart';

/// Material 3 toolbar for draw, erase, and clear-canvas actions.
///
/// Tool buttons subscribe only to [CanvasProvider.selectedTool] via
/// [context.select] so switching tools rebuilds just the two tool buttons,
/// not the palette or pixel grid.
class EditingToolbar extends StatelessWidget {
  const EditingToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _ToolButton(
            tool: DrawingTool.draw,
            icon: Icons.brush_rounded,
            label: 'Draw',
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          const _ToolButton(
            tool: DrawingTool.erase,
            icon: Icons.auto_fix_off_rounded,
            label: 'Eraser',
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          const _ClearCanvasButton(),
        ],
      ),
    );
  }
}

/// A single tool toggle button with Material 3 selected styling.
///
/// Delegates selection to [CanvasProvider.changeDrawingTool] — the widget
/// only reflects state and forwards taps.
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.tool,
    required this.icon,
    required this.label,
  });

  final DrawingTool tool;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<CanvasProvider, bool>(
      (provider) => provider.selectedTool == tool,
    );

    final theme = Theme.of(context);

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          onTap: isSelected
              ? null
              : () => context.read<CanvasProvider>().changeDrawingTool(tool),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clears all painted pixels without resetting color or tool selection.
///
/// Uses [context.read] so this button never rebuilds on canvas changes —
/// [CanvasProvider.clearCanvas] handles the no-op when the grid is empty.
class _ClearCanvasButton extends StatelessWidget {
  const _ClearCanvasButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Clear canvas',
      button: true,
      child: OutlinedButton.icon(
        onPressed: () => context.read<CanvasProvider>().clearCanvas(),
        icon: Icon(
          Icons.delete_sweep_rounded,
          size: 20,
          color: theme.colorScheme.error,
        ),
        label: Text(
          'Clear',
          style: TextStyle(color: theme.colorScheme.error),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall,
          ),
        ),
      ),
    );
  }
}

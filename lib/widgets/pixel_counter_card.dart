import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/canvas_provider.dart';

/// Live display of painted vs total canvas cells.
///
/// Subscribes to [CanvasProvider.filledPixelCount] and
/// [CanvasProvider.totalPixelCount] via [context.select] so only this card
/// rebuilds when counts change — not the palette, toolbar, or pixel grid.
class PixelCounterCard extends StatelessWidget {
  const PixelCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final counts = context.select<CanvasProvider, ({int filled, int total})>(
      (provider) => (
        filled: provider.filledPixelCount,
        total: provider.totalPixelCount,
      ),
    );

    final theme = Theme.of(context);
    final progress = counts.total == 0 ? 0.0 : counts.filled / counts.total;
    final percent = (progress * 100).round();

    return Semantics(
      label: 'Canvas usage ${counts.filled} of ${counts.total} pixels',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.grid_on_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: Text(
                    'Canvas Usage',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${counts.filled} / ${counts.total}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.surface.withValues(alpha: 0.6),
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percent% filled',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

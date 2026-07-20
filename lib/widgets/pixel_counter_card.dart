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

    return Semantics(
      label: 'Filled pixels ${counts.filled} of ${counts.total}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filled Pixels',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            '${counts.filled} / ${counts.total}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

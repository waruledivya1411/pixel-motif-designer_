import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/canvas_provider.dart';
import '../providers/motif_provider.dart';
import '../services/export_result.dart';

/// Export controls for saving the current motif as a PNG.
///
/// Delegates all export work to [MotifProvider] and [ExportService] —
/// this widget only triggers the action and shows feedback via SnackBar.
class ExportSection extends StatelessWidget {
  const ExportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isExporting = context.select<MotifProvider, bool>(
      (provider) => provider.isExporting,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: isExporting ? null : () => _handleExport(context),
          icon: isExporting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.image_outlined),
          label: Text(isExporting ? 'Exporting…' : 'Export PNG'),
        ),
      ),
    );
  }

  /// Reads canvas state, invokes export, and shows a result SnackBar.
  Future<void> _handleExport(BuildContext context) async {
    final canvasState = context.read<CanvasProvider>().state;
    final result = await context.read<MotifProvider>().exportPng(canvasState);

    if (!context.mounted) return;

    final message = switch (result) {
      ExportResult.success => '✅ PNG exported successfully',
      ExportResult.failure => '❌ Export failed',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

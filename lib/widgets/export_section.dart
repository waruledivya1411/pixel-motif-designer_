import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/canvas_provider.dart';
import '../providers/motif_provider.dart';
import '../services/export_result.dart';

/// Export controls for saving the current motif as PNG or SVG.
///
/// Delegates all export work to [MotifProvider] and [ExportService] —
/// this widget only triggers actions and shows feedback via SnackBar.
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
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed:
                  isExporting ? null : () => _handlePngExport(context),
              icon: _buildIcon(context, isExporting, Icons.image_outlined),
              label: Text(isExporting ? 'Exporting…' : 'Export PNG'),
            ),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
                  isExporting ? null : () => _handleSvgExport(context),
              icon: _buildIcon(context, isExporting, Icons.code_rounded),
              label: const Text('Export SVG'),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a spinner while export is running, otherwise the given [icon].
  Widget _buildIcon(BuildContext context, bool isExporting, IconData icon) {
    if (!isExporting) return Icon(icon);

    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _handlePngExport(BuildContext context) async {
    final canvasState = context.read<CanvasProvider>().state;
    final result = await context.read<MotifProvider>().exportPng(canvasState);
    if (!context.mounted) return;
    _showSnackBar(
      context,
      successMessage: '✅ PNG exported successfully',
      failureMessage: '❌ Export failed',
      result: result,
    );
  }

  Future<void> _handleSvgExport(BuildContext context) async {
    final canvasState = context.read<CanvasProvider>().state;
    final result = await context.read<MotifProvider>().exportSvg(canvasState);
    if (!context.mounted) return;
    _showSnackBar(
      context,
      successMessage: '✅ SVG exported successfully',
      failureMessage: '❌ SVG export failed',
      result: result,
    );
  }

  void _showSnackBar(
    BuildContext context, {
    required String successMessage,
    required String failureMessage,
    required ExportResult result,
  }) {
    final message = switch (result) {
      ExportResult.success => successMessage,
      ExportResult.failure => failureMessage,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

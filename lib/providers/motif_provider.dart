import 'package:flutter/foundation.dart';

import '../models/canvas_state.dart';
import '../services/export_result.dart';
import '../services/export_service.dart';

/// Orchestrates motif export, import, and persistence operations.
///
/// Coordinates between [CanvasProvider] and [ExportService] so the UI
/// triggers exports with a single call while remaining unaware of PNG
/// encoding or platform save details.
class MotifProvider extends ChangeNotifier {
  MotifProvider({ExportService? exportService})
      : _exportService = exportService ?? ExportService();

  final ExportService _exportService;

  /// Whether an export is currently in progress.
  bool _isExporting = false;

  /// Read-only export-in-progress flag for disabling export buttons.
  bool get isExporting => _isExporting;

  /// Exports [canvasState] as a PNG via [ExportService].
  ///
  /// Returns an [ExportResult] for the UI to display in a SnackBar.
  /// Does not mutate canvas state — export is read-only with respect to pixels.
  Future<ExportResult> exportPng(CanvasState canvasState) async {
    return _runExport(
      () => _exportService.exportMotifAsPng(canvasState),
    );
  }

  /// Exports [canvasState] as an SVG via [ExportService].
  ///
  /// Saves to Downloads/Documents asynchronously without blocking the UI.
  Future<ExportResult> exportSvg(CanvasState canvasState) async {
    return _runExport(
      () => _exportService.exportMotifAsSvg(canvasState),
    );
  }

  /// Runs an export operation while tracking [isExporting] for the UI.
  Future<ExportResult> _runExport(
    Future<ExportResult> Function() exportAction,
  ) async {
    if (_isExporting) return ExportResult.failure;

    _isExporting = true;
    notifyListeners();

    try {
      return await exportAction();
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}

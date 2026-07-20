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

  /// Whether a PNG export is currently in progress.
  bool _isExporting = false;

  /// Read-only export-in-progress flag for disabling the export button.
  bool get isExporting => _isExporting;

  /// Exports [canvasState] as a PNG via [ExportService].
  ///
  /// Returns an [ExportResult] for the UI to display in a SnackBar.
  /// Does not mutate canvas state — export is read-only with respect to pixels.
  Future<ExportResult> exportPng(CanvasState canvasState) async {
    if (_isExporting) return ExportResult.failure;

    _isExporting = true;
    notifyListeners();

    try {
      return await _exportService.exportMotifAsPng(canvasState);
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }
}

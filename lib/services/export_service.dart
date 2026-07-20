import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/color_constants.dart';
import '../core/constants/grid_constants.dart';
import '../models/canvas_state.dart';
import 'export_result.dart';

/// Handles PNG generation and platform-specific saving for motif exports.
///
/// Keeps file I/O, permission requests, and image encoding out of widgets
/// and providers — this class is the single place that talks to [Gal] and
/// the filesystem.
class ExportService {
  /// Creates an [ExportService] with optional overrides for testing.
  ExportService({
    Future<Uint8List> Function(CanvasState state)? pngEncoder,
    Future<void> Function(Uint8List bytes, String fileName)? gallerySaver,
    Future<void> Function(Uint8List bytes, String fileName)? fileSaver,
  })  : _pngEncoder = pngEncoder ?? _encodeCanvasAsPng,
        _gallerySaver = gallerySaver ?? _saveToGallery,
        _fileSaver = fileSaver ?? _saveToDownloadsOrDocuments;

  final Future<Uint8List> Function(CanvasState state) _pngEncoder;
  final Future<void> Function(Uint8List bytes, String fileName) _gallerySaver;
  final Future<void> Function(Uint8List bytes, String fileName) _fileSaver;

  /// Generates a PNG from [state] and saves it to the gallery or filesystem.
  Future<ExportResult> exportMotifAsPng(CanvasState state) async {
    try {
      final bytes = await _pngEncoder(state);
      final fileName = _buildFileName();

      if (Platform.isAndroid || Platform.isIOS) {
        final savedToGallery = await _trySaveToGallery(bytes, fileName);
        if (savedToGallery) return ExportResult.success;
      }

      await _fileSaver(bytes, fileName);
      return ExportResult.success;
    } catch (_) {
      return ExportResult.failure;
    }
  }

  /// Attempts gallery save with on-demand permission request.
  Future<bool> _trySaveToGallery(Uint8List bytes, String fileName) async {
    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }

      await _gallerySaver(bytes, fileName);
      return true;
    } on GalException {
      return false;
    }
  }

  static Future<void> _saveToGallery(Uint8List bytes, String fileName) {
    return Gal.putImageBytes(bytes, name: fileName);
  }

  /// Fallback when gallery access is denied or unavailable (desktop / web).
  static Future<void> _saveToDownloadsOrDocuments(
    Uint8List bytes,
    String fileName,
  ) async {
    final directory = await _resolveFallbackDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
  }

  static Future<Directory> _resolveFallbackDirectory() async {
    if (Platform.isAndroid) {
      final downloads = Directory('/storage/emulated/0/Download');
      if (await downloads.exists()) return downloads;
    }

    final downloads = await getDownloadsDirectory();
    if (downloads != null) return downloads;

    return getApplicationDocumentsDirectory();
  }

  static String _buildFileName() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'pixel_motif_$timestamp.png';
  }

  /// Renders the pixel matrix from [state] into PNG bytes.
  ///
  /// Each grid cell is scaled to [GridConstants.exportCellPixelSize] so the
  /// exported image reflects exactly what the user painted — no UI chrome,
  /// borders, or gesture layers.
  static Future<Uint8List> _encodeCanvasAsPng(CanvasState state) async {
    final cellSize = GridConstants.exportCellPixelSize;
    final width = state.gridColumns * cellSize;
    final height = state.gridRows * cellSize;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final backgroundPaint = Paint()..color = ColorConstants.canvasBackground;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      backgroundPaint,
    );

    for (var row = 0; row < state.gridRows; row++) {
      for (var column = 0; column < state.gridColumns; column++) {
        final pixel = state.pixels[row][column];
        final paint = Paint()
          ..color = pixel.isFilled
              ? Color(pixel.color)
              : ColorConstants.canvasBackground;

        canvas.drawRect(
          Rect.fromLTWH(
            column * cellSize.toDouble(),
            row * cellSize.toDouble(),
            cellSize.toDouble(),
            cellSize.toDouble(),
          ),
          paint,
        );
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw StateError('Failed to encode PNG byte data.');
    }

    return byteData.buffer.asUint8List();
  }
}

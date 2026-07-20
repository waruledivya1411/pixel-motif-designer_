import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Saves files to the public Downloads folder on Android via MediaStore.
///
/// Uses a platform channel so SVG exports land in a user-visible location
/// without relying on the system share sheet.
abstract final class PlatformDownloadSaver {
  static const MethodChannel _channel = MethodChannel(
    'com.pixelmotif.pixel_motif_designer/downloads',
  );

  /// Writes [content] to Downloads/Pixel Motif Designer on Android.
  ///
  /// Returns the saved file name on success, or `null` when unavailable.
  static Future<String?> saveText({
    required String content,
    required String fileName,
    String mimeType = 'image/svg+xml',
  }) async {
    if (!Platform.isAndroid) return null;

    try {
      final saved = await _channel.invokeMethod<String>(
        'saveToDownloads',
        {
          'fileName': fileName,
          'mimeType': mimeType,
          'bytes': Uint8List.fromList(utf8.encode(content)),
        },
      );
      return saved;
    } on PlatformException {
      return null;
    }
  }
}

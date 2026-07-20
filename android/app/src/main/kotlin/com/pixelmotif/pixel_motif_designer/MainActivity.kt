package com.pixelmotif.pixel_motif_designer

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.pixelmotif.pixel_motif_designer/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads" -> {
                        val fileName = call.argument<String>("fileName")
                        val mimeType = call.argument<String>("mimeType")
                        val bytes = call.argument<ByteArray>("bytes")

                        if (fileName == null || mimeType == null || bytes == null) {
                            result.error("INVALID_ARGS", "Missing save arguments", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val savedName = saveToDownloads(fileName, mimeType, bytes)
                            if (savedName != null) {
                                result.success(savedName)
                            } else {
                                result.error("SAVE_FAILED", "Could not save file", null)
                            }
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun saveToDownloads(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            saveViaMediaStore(fileName, mimeType, bytes)
        } else {
            saveViaLegacyDownloads(fileName, bytes)
        }
    }

    private fun saveViaMediaStore(
        fileName: String,
        mimeType: String,
        bytes: ByteArray,
    ): String? {
        val resolver = contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(
                MediaStore.MediaColumns.RELATIVE_PATH,
                "${Environment.DIRECTORY_DOWNLOADS}/Pixel Motif Designer",
            )
        }

        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, contentValues)
            ?: return null

        resolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(bytes)
            outputStream.flush()
        } ?: return null

        return fileName
    }

    @Suppress("DEPRECATION")
    private fun saveViaLegacyDownloads(fileName: String, bytes: ByteArray): String? {
        val downloadsDir = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS,
        )
        val appDir = File(downloadsDir, "Pixel Motif Designer")
        if (!appDir.exists() && !appDir.mkdirs()) {
            return null
        }

        val file = File(appDir, fileName)
        file.writeBytes(bytes)
        return fileName
    }
}

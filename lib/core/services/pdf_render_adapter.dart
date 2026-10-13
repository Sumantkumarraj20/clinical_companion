import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdf_render_maintained/pdf_render.dart';
import 'package:pdf_render_maintained/pdf_render_widgets.dart';

/// Adapter isolating `pdf_render_maintained` from platforms that lack
/// native implementation (specifically Windows).
class PdfRenderAdapter {
  const PdfRenderAdapter._();

  /// Whether PDF rendering is supported on the current platform.
  static bool get isSupported => !Platform.isWindows;

  /// Builds a PDF viewer widget, or a fallback placeholder on Windows.
  static Widget buildViewer(
    String filePath, {
    Key? key,
    BoxFit fit = BoxFit.contain,
  }) {
    if (Platform.isWindows) {
      return Center(
        key: key,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'PDF preview is not supported on Windows.',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return PdfViewer.openFile(filePath, key: key);
  }

  /// Opens a PDF document if supported on the current platform.
  /// Returns `null` on Windows or unsupported platforms.
  static Future<PdfDocument?> openFile(String filePath) async {
    if (Platform.isWindows) {
      return null;
    }
    try {
      return await PdfDocument.openFile(filePath);
    } catch (_) {
      return null;
    }
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Longest edge, in pixels, of an image sent for a deep scan.
const int kDeepScanMaxDimension = 1536;

/// JPEG quality used for deep-scan uploads.
const int kDeepScanJpegQuality = 80;

/// Resizes (aspect ratio preserved, never enlarged) so the longest edge is at
/// most [maxDimension], then encodes as JPEG at [quality].
Uint8List optimizeImageBytes(
  Uint8List bytes, {
  int maxDimension = kDeepScanMaxDimension,
  int quality = kDeepScanJpegQuality,
}) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Unreadable image.');
  }
  var oriented = img.bakeOrientation(decoded);
  final longest = oriented.width > oriented.height
      ? oriented.width
      : oriented.height;
  if (longest > maxDimension) {
    oriented = oriented.width >= oriented.height
        ? img.copyResize(oriented, width: maxDimension)
        : img.copyResize(oriented, height: maxDimension);
  }
  return Uint8List.fromList(img.encodeJpg(oriented, quality: quality));
}

/// Reads [file] and optimizes it off the UI isolate.
Future<Uint8List> optimizeImageFile(File file) async {
  final bytes = await file.readAsBytes();
  return compute(optimizeImageBytes, bytes);
}

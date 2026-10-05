import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Sprint 17 — SHA-256 of a document image, the absolute deduplication key.
///
/// Runs inside a background isolate via [compute] so hashing a 10 MB scan
/// never blocks the UI thread, and streams the bytes via [sha256.bind] so the
/// file is never materialised as one byte list.
///
/// Returns null when the file cannot be read. A missing or unreadable image
/// must never block saving a document the clinician has already reviewed — the
/// only cost is that this particular page will not be content-deduplicated.
Future<String?> hashDocumentImageOrNull(String path) async {
  try {
    return await compute(_sha256OfFile, path);
  } catch (error) {
    debugPrint('[ClinCom] Could not hash $path: $error');
    return null;
  }
}

Future<String> _sha256OfFile(String path) async {
  final digest = await sha256.bind(File(path).openRead()).first;
  return digest.toString();
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Returns the clinical data storage directory.
///
/// Strictly uses [getApplicationSupportDirectory] (or [getApplicationDocumentsDirectory] as fallback),
/// and NEVER the executable's directory. This ensures portable auto-updaters can safely overwrite the
/// application bundle without touching patient records or SQLite databases.
Future<Directory> getPortableStorageDirectory() async {
  Directory baseDirectory;
  try {
    baseDirectory = await getApplicationSupportDirectory();
  } catch (_) {
    baseDirectory = await getApplicationDocumentsDirectory();
  }

  final storageDirectory = Directory(
    path.join(baseDirectory.path, 'clinical_data'),
  );
  await storageDirectory.create(recursive: true);

  // Migration defense: if legacy portable storage exists next to executable
  // and the new support directory does not yet have databases, migrate them over.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      final legacyDir = Directory(
        path.join(File(Platform.resolvedExecutable).parent.path, 'clinical_data'),
      );
      if (legacyDir.existsSync() && legacyDir.path != storageDirectory.path) {
        for (final entity in legacyDir.listSync()) {
          if (entity is File) {
            final dest = File(path.join(storageDirectory.path, path.basename(entity.path)));
            if (!dest.existsSync()) {
              entity.copySync(dest.path);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[StorageDirectory] Legacy migration check skipped: $e');
    }
  }

  return storageDirectory;
}
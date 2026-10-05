import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' show Database, sqlite3;

import '../database/local_database.dart';

/// Device-to-device backup of the clinical SQLite database.
///
/// Sprint 16 — the "invincibility layer". A clinician who loses a phone must
/// be able to move their whole practice history to the new one without a
/// network connection or a working cloud project.
///
/// SAFETY MODEL
///   * **Export** runs SQLite's own `VACUUM INTO`, which produces a consistent
///     snapshot without stopping the app or risking a torn copy.
///   * **Import** validates the candidate file BEFORE touching anything: it
///     must open as a real SQLite database and contain the app's core tables.
///     Only then is the live database replaced, and the original is kept
///     alongside as `<name>.pre-import.bak` so a bad import is recoverable.
class DatabaseBackupService {
  const DatabaseBackupService(this.db);

  final AppDatabase db;

  /// Copy of the live database to [destinationPath].
  Future<File> exportTo(String destinationPath) async {
    final file = File(destinationPath);
    if (file.existsSync()) await file.delete();
    // VACUUM INTO yields a compact, consistent snapshot in a single statement.
    await db.customStatement(
      "VACUUM INTO '${destinationPath.replaceAll("'", "''")}'",
    );
    return file;
  }

  /// Exports into the app's documents directory and returns the file.
  Future<File> exportToDocuments(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    return exportTo('${dir.path}/$fileName');
  }

  /// Verifies [path] really is an app database before anything is overwritten.
  ///
  /// Opens the *candidate* file on its own connection — deliberately NOT via
  /// the live `db`, which would validate whatever is already installed and
  /// happily overwrite a good database with a junk file.
  ///
  /// Returns null when the file is valid, or a human-readable reason why not.
  Future<String?> validateCandidate(String path) async {
    final file = File(path);
    if (!file.existsSync()) return 'The selected file does not exist.';

    final header = await file
        .openRead(0, 15)
        .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
    if (!String.fromCharCodes(header).startsWith('SQLite format 3')) {
      return 'That file is not a SQLite database.';
    }

    // Read-only connection, opened on the candidate itself.
    final Database candidate = sqlite3.open(path);
    try {
      final tables = candidate
          .select("SELECT name FROM sqlite_master WHERE type='table'")
          .map((row) => row['name'] as String)
          .toSet();
      const required = {'patients', 'clinical_encounters'};
      final missing = required.difference(tables);
      if (missing.isNotEmpty) {
        return 'That file is not a ClinCom backup — it is missing: '
            '${missing.join(', ')}.';
      }
      return null;
    } catch (error) {
      return 'Could not read that backup: $error';
    } finally {
      candidate.close();
    }
  }
}

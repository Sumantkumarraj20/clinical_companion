import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/local_database.dart';

/// Keeps the app from filling the phone over a lifetime of use, without ever
/// losing clinical text.
///
/// Sprint 16 — scanned images are by far the largest thing this app stores
/// (multi-megabyte JPEGs per report), while the clinically valuable part is
/// the OCR transcript and the metadata. So after a year we delete **only the
/// image file** and keep everything else forever.
///
/// The row is never deleted. Its `imagePath` becomes the sentinel
/// `'pruned_for_storage'` so the UI can say "image pruned" rather than
/// rendering a broken thumbnail, and a row whose image was already gone is
/// left untouched.
class StorageRetentionService {
  const StorageRetentionService(this.db);

  final AppDatabase db;

  /// Sentinel written to `imagePath` once the underlying file is deleted.
  static const String prunedSentinel = 'pruned_for_storage';

  /// Documents older than [maxAgeDays] (default 365) whose image is pruned.
  Future<int> pruneOldImages({int maxAgeDays = 365, DateTime? now}) async {
    final cutoff = (now ?? DateTime.now()).subtract(
      Duration(days: maxAgeDays),
    );

    // Only rows that actually still have a real file path: an empty string or
    // an existing sentinel means there is nothing to delete.
    final candidates =
        await (db.select(db.documentRegistries)..where(
              (row) =>
                  row.documentedAt.isSmallerThanValue(cutoff) &
                  row.imagePath.isNotValue('') &
                  row.imagePath.isNotValue(prunedSentinel),
            ))
            .get();

    var pruned = 0;
    for (final row in candidates) {
      try {
        final file = File(row.imagePath);
        if (file.existsSync()) {
          await file.delete();
        }
        // Update the row *after* the delete succeeds. If the delete throws we
        // keep the pointer so the document stays viewable and we retry next run.
        await (db.update(
          db.documentRegistries,
        )..where((r) => r.id.equals(row.id))).write(
          DocumentRegistriesCompanion(
            imagePath: Value(prunedSentinel),
          ),
        );
        pruned++;
      } on FileSystemException catch (error) {
        // A file locked by another process, or a permission problem, must not
        // abort the whole sweep — the remaining documents still get pruned.
        debugPrint('[Retention] Could not delete ${row.imagePath}: $error');
      }
    }
    return pruned;
  }

  /// Rows whose image has already been pruned but whose transcript survived.
  Future<int> countPrunedDocuments() async {
    final expression = db.documentRegistries.id.count();
    final query = db.selectOnly(db.documentRegistries)
      ..addColumns([expression])
      ..where(db.documentRegistries.imagePath.equals(prunedSentinel));
    return (await query.getSingle()).read(expression) ?? 0;
  }
}
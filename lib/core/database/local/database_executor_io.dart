import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../utils/portable_directory.dart';

/// NativeDatabase keeps SQLite work off the Flutter UI isolate.
QueryExecutor openAppDatabaseExecutor() {
  return LazyDatabase(() async {

    if (kIsWeb) {
      throw UnsupportedError(
        'Native IO accessed on Web. Check conditional exports.',
      );
    }
    
    final directory = await getPortableStorageDirectory();
    final file = File(p.join(directory.path, 'clinical_drugs.sqlite'));
    if (!await file.exists()) {
      final blob = await rootBundle.load('assets/clinical_drugs.sqlite');
      final buffer = blob.buffer;
      await file.writeAsBytes(
        buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes),
      );
    }
    return NativeDatabase.createInBackground(
      file,
      setup: (database) {
        database.execute('PRAGMA journal_mode = WAL');
        database.execute('PRAGMA synchronous = NORMAL');
        database.execute('PRAGMA busy_timeout = 5000');
        database.execute('PRAGMA foreign_keys = ON');
      },
    );
  });
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

/// NativeDatabase keeps SQLite work off the Flutter UI isolate.
QueryExecutor openAppDatabaseExecutor() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'medassit.sqlite'));
    final catalog = File(p.join(directory.path, 'clinical_drugs.sqlite'));
    if (!await catalog.exists()) {
      try {
        final bundled = await rootBundle.load('assets/clinical_drugs.sqlite');
        await catalog.writeAsBytes(bundled.buffer.asUint8List(), flush: true);
      } on FlutterError {
        // The catalog asset is optional for development builds.
      }
    }
    return NativeDatabase.createInBackground(file);
  });
}

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// drift_flutter selects the browser's IndexedDB/WASM implementation on web.
/// The native counterpart is explicitly backed by NativeDatabase in the IO
/// implementation exported for Android and desktop targets.
QueryExecutor openAppDatabaseExecutor() => driftDatabase(name: 'medassit');

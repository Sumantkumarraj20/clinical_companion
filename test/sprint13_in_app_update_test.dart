import 'dart:io';

import 'package:clinical_companion/core/services/in_app_update_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';

/// Local HTTP server serving an APK-sized body, so the real `Dio` transfer
/// path (streaming + progress callbacks) is exercised rather than stubbed.
class _FakeReleaseServer {
  _FakeReleaseServer(
    this.payload, {
    this.statusCode = 200,
    this.stallAfterChunk = false,
  });

  final List<int> payload;
  final int statusCode;

  /// Sends the payload, then hangs without closing the response. The client is
  /// left genuinely mid-transfer, which makes cancellation deterministic
  /// instead of racing a transfer that already completed.
  final bool stallAfterChunk;

  HttpServer? _server;
  Uri? uri;

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    uri = Uri.parse(
      'http://${_server!.address.address}:${_server!.port}/update.apk',
    );
    _server!.listen((request) async {
      final response = request.response
        ..statusCode = statusCode
        ..headers.contentType = ContentType('application', 'octet-stream');
      if (statusCode == 200) {
        response.headers.contentLength = payload.length;
        // Dribble the body out so onReceiveProgress fires more than once.
        for (var offset = 0; offset < payload.length; offset += 1024) {
          final end = (offset + 1024).clamp(0, payload.length);
          response.add(payload.sublist(offset, end));
          await response.flush();
          if (stallAfterChunk && offset > 0) {
            // Never close: the transfer stays in flight until cancelled.
            return;
          }
        }
      }
      await response.close();
    });
  }

  Future<void> stop() async {
    await _server?.close(force: true);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('in_app_update_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  InAppUpdateManager managerFor({
    Future<OpenResult> Function(String path)? opener,
  }) {
    return InAppUpdateManager(
      directoryProvider: () async => tempDir,
      opener: opener ?? (path) async => OpenResult(),
    );
  }

  test('downloads the APK and opens it with the platform installer', () async {
    final server = _FakeReleaseServer(List.filled(8192, 65));
    await server.start();
    addTearDown(server.stop);

    final opened = <String>[];
    final progress = <double>[];

    await managerFor(
      opener: (path) async {
        opened.add(path);
        return OpenResult();
      },
    ).downloadAndInstall(
      apkUrl: server.uri!.toString(),
      onProgress: progress.add,
    );

    final saved = File('${tempDir.path}/ota/update.apk');
    expect(saved.existsSync(), isTrue);
    expect(saved.lengthSync(), 8192);
    expect(opened, [saved.path]);

    // Progress must start at 0 and finish at exactly 1.
    expect(progress.first, 0);
    expect(progress.last, 1);
    expect(
      progress.every((value) => value >= 0 && value <= 1),
      isTrue,
      reason: 'fraction must never escape 0..1',
    );
  });

  test('reports byte counts while transferring', () async {
    final server = _FakeReleaseServer(List.filled(4096, 1));
    await server.start();
    addTearDown(server.stop);

    final totals = <int>[];
    await managerFor().downloadAndInstall(
      apkUrl: server.uri!.toString(),
      onProgress: (_) {},
      onBytes: (received, total) => totals.add(total),
    );

    expect(totals, isNotEmpty);
    expect(totals.every((total) => total == 4096), isTrue);
  });

  test(
    'submits the private APK path to the injected native installer',
    () async {
      final server = _FakeReleaseServer(List.filled(1024, 9));
      await server.start();
      addTearDown(server.stop);

      String? submittedPath;
      await InAppUpdateManager(
        directoryProvider: () async => tempDir,
        installer: (path) async {
          submittedPath = path;
        },
      ).downloadAndInstall(apkUrl: server.uri!.toString(), onProgress: (_) {});

      expect(submittedPath, '${tempDir.path}/ota/update.apk');
      expect(File(submittedPath!).existsSync(), isTrue);
    },
  );

  test('a cached APK is opened without downloading it again', () async {
    final cached = File('${tempDir.path}/ota/update.apk')
      ..createSync(recursive: true)
      ..writeAsBytesSync(List.filled(10, 0));
    final opened = <String>[];

    await managerFor(
      opener: (path) async {
        opened.add(path);
        return OpenResult();
      },
    ).downloadAndInstall(
      apkUrl: 'http://127.0.0.1:1/update.apk',
      onProgress: (_) {},
    );

    expect(opened, [cached.path]);
    expect(cached.lengthSync(), 10);
  });

  test('an empty partial APK is cleared before downloading again', () async {
    final partial = File('${tempDir.path}/ota/update.apk')
      ..createSync(recursive: true)
      ..writeAsBytesSync([]);
    final server = _FakeReleaseServer(List.filled(2048, 7));
    await server.start();
    addTearDown(server.stop);

    await managerFor().downloadAndInstall(
      apkUrl: server.uri!.toString(),
      onProgress: (_) {},
    );

    expect(partial.lengthSync(), 2048, reason: 'partial file was replaced');
  });

  test(
    'a failed cached install clears the APK so the next attempt downloads',
    () async {
      final cached = File('${tempDir.path}/ota/update.apk')
        ..createSync(recursive: true)
        ..writeAsBytesSync(List.filled(10, 0));

      await expectLater(
        managerFor(
          opener: (_) async => OpenResult(
            type: ResultType.noAppToOpen,
            message: 'corrupted APK',
          ),
        ).downloadAndInstall(
          apkUrl: 'http://127.0.0.1:1/update.apk',
          onProgress: (_) {},
        ),
        throwsA(isA<InAppUpdateException>()),
      );
      expect(cached.existsSync(), isFalse);

      final server = _FakeReleaseServer(List.filled(2048, 7));
      await server.start();
      addTearDown(server.stop);

      await managerFor().downloadAndInstall(
        apkUrl: server.uri!.toString(),
        onProgress: (_) {},
      );
      expect(cached.lengthSync(), 2048);
    },
  );

  test(
    'an HTTP error is surfaced as an http failure, not a silent no-op',
    () async {
      final server = _FakeReleaseServer(const [], statusCode: 404);
      await server.start();
      addTearDown(server.stop);

      await expectLater(
        managerFor().downloadAndInstall(
          apkUrl: server.uri!.toString(),
          onProgress: (_) {},
        ),
        throwsA(
          isA<InAppUpdateException>().having(
            (e) => e.kind,
            'kind',
            InAppUpdateErrorKind.http,
          ),
        ),
      );
    },
  );

  test('an unreachable host is surfaced as a network failure', () async {
    // Port 1 on loopback refuses connections.
    await expectLater(
      managerFor().downloadAndInstall(
        apkUrl: 'http://127.0.0.1:1/update.apk',
        onProgress: (_) {},
      ),
      throwsA(
        isA<InAppUpdateException>().having(
          (e) => e.kind,
          'kind',
          InAppUpdateErrorKind.network,
        ),
      ),
    );
  });

  test(
    'a refused installer is reported instead of pretending to succeed',
    () async {
      final server = _FakeReleaseServer(List.filled(128, 3));
      await server.start();
      addTearDown(server.stop);

      await expectLater(
        managerFor(
          opener: (path) async =>
              OpenResult(type: ResultType.noAppToOpen, message: 'no app'),
        ).downloadAndInstall(
          apkUrl: server.uri!.toString(),
          onProgress: (_) {},
        ),
        throwsA(
          isA<InAppUpdateException>().having(
            (e) => e.kind,
            'kind',
            InAppUpdateErrorKind.install,
          ),
        ),
      );
    },
  );

  test('a malformed URL is rejected before any network call', () async {
    await expectLater(
      managerFor().downloadAndInstall(apkUrl: 'not a url', onProgress: (_) {}),
      throwsA(
        isA<InAppUpdateException>().having(
          (e) => e.kind,
          'kind',
          InAppUpdateErrorKind.http,
        ),
      ),
    );
  });

  test('cancel stops the transfer and leaves no partial APK', () async {
    // A stalling server keeps the transfer genuinely in flight, so the cancel
    // lands mid-download instead of racing one that already completed.
    final server = _FakeReleaseServer(
      List.filled(64 * 1024, 4),
      stallAfterChunk: true,
    );
    await server.start();
    addTearDown(server.stop);

    final manager = managerFor();
    final future = manager.downloadAndInstall(
      apkUrl: server.uri!.toString(),
      onProgress: (_) {},
    );

    // Cancel from outside the progress callback: Dio defers a cancellation
    // raised mid-callback until the current socket event completes, which
    // never happens against a stalled server.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    manager.cancel();

    await expectLater(
      future,
      throwsA(
        isA<InAppUpdateException>().having(
          (e) => e.message.toLowerCase(),
          'message',
          contains('cancel'),
        ),
      ),
    );
    expect(
      File('${tempDir.path}/ota/update.apk').existsSync(),
      isFalse,
      reason: 'deleteOnError must not leave a truncated APK behind',
    );
  });

  test('cleanup removes a previously downloaded APK', () async {
    final file = File('${tempDir.path}/ota/update.apk')
      ..createSync(recursive: true)
      ..writeAsBytesSync([1, 2, 3]);
    await managerFor().cleanup();
    expect(file.existsSync(), isFalse);
  });

  test('a transport error maps to a network failure', () {
    final mapped = toExceptionForTesting(
      DioException(requestOptions: RequestOptions(path: '/x')),
    );
    expect(mapped.kind, InAppUpdateErrorKind.network);
    expect(mapped.message, contains('connection'));
  });
}

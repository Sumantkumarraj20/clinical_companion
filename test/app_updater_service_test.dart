import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:clinical_companion/core/services/app_updater_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  PackageInfo localInfo(String version) => PackageInfo(
    appName: 'Clinical Companion',
    packageName: 'com.clinical.companion',
    version: version,
    buildNumber: '1',
  );

  String releaseJson({
    String tag = 'v2.0.0',
    List<Map<String, dynamic>>? assets,
  }) => jsonEncode({
    'tag_name': tag,
    'name': 'Clinical Companion $tag',
    'html_url':
        'https://github.com/Sumantkumarraj20/clinical_companion/releases/tag/$tag',
    'assets':
        assets ??
        [
          {
            'name': 'app-release.apk',
            'browser_download_url':
                'https://github.com/Sumantkumarraj20/clinical_companion/'
                'releases/download/v2.0.0/app-release.apk',
          },
          {
            'name': 'debug.zip',
            'browser_download_url': 'https://example.com/debug.zip',
          },
        ],
  });

  AppUpdaterService serviceWith({
    required http.Client client,
    String version = '1.0.0',
    String? releasesUrl,
  }) => AppUpdaterService(
    httpClient: client,
    packageInfoLoader: () async => localInfo(version),
    releasesUrl: releasesUrl ?? AppUpdaterService.defaultReleasesUrl,
  );

  group('checkForUpdate', () {
    test('checkForUpdates exposes the APK and release page', () async {
      final service = serviceWith(
        version: '1.0.4',
        client: MockClient(
          (_) async => http.Response(releaseJson(tag: 'v1.0.5'), 200),
        ),
      );

      final update = await service.checkForUpdates();

      expect(update, isA<UpdateAvailable>());
      expect(update?.apkUrl, contains('app-release.apk'));
      expect(update?.releaseUrl, contains('/releases/tag/v1.0.5'));
    });

    test('returns the APK browser_download_url when remote is newer', () async {
      final requested = <http.Request>[];
      final service = serviceWith(
        version: '1.0.4',
        client: MockClient((request) async {
          requested.add(request);
          return http.Response(
            releaseJson(tag: 'v1.0.5'),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final url = await service.checkForUpdate();

      expect(
        url,
        startsWith(
          'https://github.com/Sumantkumarraj20/clinical_companion/'
          'releases/download/v2.0.0/app-release.apk?t=',
        ),
      );
      expect(
        requested.single.url.toString(),
        AppUpdaterService.defaultReleasesUrl,
      );
      expect(requested.single.headers['Accept'], 'application/vnd.github+json');
    });

    test(
      'provides normalized local and remote versions for the banner',
      () async {
        final service = serviceWith(
          version: '  v1.0.4  ',
          client: MockClient(
            (_) async => http.Response(releaseJson(tag: ' v1.0.5 '), 200),
          ),
        );

        final update = await service.checkForUpdateInfo();

        expect(update?.localVersion, '1.0.4');
        expect(update?.remoteVersion, '1.0.5');
        expect(update?.apkUrl, contains('.apk'));
        expect(update?.releaseUrl, contains('/releases/tag/'));
      },
    );

    test('returns null when installed version matches the release', () async {
      final service = serviceWith(
        version: '1.0.5',
        client: MockClient(
          (_) async => http.Response(releaseJson(tag: 'v1.0.5'), 200),
        ),
      );
      expect(await service.checkForUpdate(), isNull);
    });

    test(
      'returns null when the installed version is ahead of the release',
      () async {
        final service = serviceWith(
          version: '1.1.0',
          client: MockClient(
            (_) async => http.Response(releaseJson(tag: 'v1.0.9'), 200),
          ),
        );
        expect(await service.checkForUpdate(), isNull);
      },
    );

    test('handles network errors silently (offline stays invisible)', () async {
      final offline = serviceWith(
        client: MockClient(
          (_) async => throw http.ClientException('Socket unreachable'),
        ),
      );
      expect(await offline.checkForUpdate(), isNull);

      final httpError = serviceWith(
        client: MockClient((_) async => http.Response('rate limited', 403)),
      );
      expect(await httpError.checkForUpdate(), isNull);

      final malformed = serviceWith(
        client: MockClient(
          (_) async => http.Response('<html>oops</html>', 200),
        ),
      );
      expect(await malformed.checkForUpdate(), isNull);
    });

    test('returns null when a newer release ships no .apk asset', () async {
      final service = serviceWith(
        client: MockClient(
          (_) async => http.Response(
            releaseJson(
              tag: 'v9.9.9',
              assets: [
                {
                  'name': 'source.zip',
                  'browser_download_url': 'https://example.com/source.zip',
                },
              ],
            ),
            200,
          ),
        ),
      );
      expect(await service.checkForUpdate(), isNull);
    });

    test('skips a missing tag_name instead of throwing', () async {
      final service = serviceWith(
        client: MockClient(
          (_) async => http.Response(jsonEncode({'name': 'draft'}), 200),
        ),
      );
      expect(await service.checkForUpdate(), isNull);
    });
  });

  group('isRemoteNewer', () {
    test('compares numeric segments, not string order', () {
      expect(AppUpdaterService.isRemoteNewer('1.0.9', 'v1.0.10'), isTrue);
      expect(AppUpdaterService.isRemoteNewer('1.0.10', 'v1.0.9'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('1.0.0', 'v1.0.1'), isTrue);
      expect(AppUpdaterService.isRemoteNewer('1.0.1', 'v1.0.1'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('2.0.0', 'v1.9.9'), isFalse);
    });

    test('treats missing segments as zero and strips suffixes', () {
      expect(AppUpdaterService.isRemoteNewer('1.0', 'v1.0.0'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('1.0', 'v1.0.1'), isTrue);
      expect(AppUpdaterService.isRemoteNewer('1.0.5', 'v1.0.5-rc.1'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('1.0.5', '1.0.6+12'), isTrue);
      expect(AppUpdaterService.isRemoteNewer('V1.0.5', 'v1.0.6'), isTrue);
    });

    test('rejects malformed versions conservatively', () {
      expect(AppUpdaterService.isRemoteNewer('banana', 'v1.0.0'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('1.0.0', 'vNext'), isFalse);
      expect(AppUpdaterService.isRemoteNewer('', 'v1.0.0'), isFalse);
    });
  });

  group('clearOldUpdateFiles', () {
    test('removes old apk files from target directory and ota subdirectory', () async {
      final tempDir = Directory.systemTemp.createTempSync('updater_test_clear_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final rootApk = File('${tempDir.path}/app-release.apk')..writeAsStringSync('old');
      final otaDir = Directory('${tempDir.path}/ota')..createSync(recursive: true);
      final otaApk = File('${otaDir.path}/app-release.apk')..writeAsStringSync('old ota');
      final updateApk = File('${otaDir.path}/update.apk')..writeAsStringSync('old update');

      final service = AppUpdaterService();
      await service.clearOldUpdateFiles(tempDir);

      expect(rootApk.existsSync(), isFalse);
      expect(otaApk.existsSync(), isFalse);
      expect(updateApk.existsSync(), isFalse);
    });
  });

  group('downloadAndApplyDesktopUpdate', () {
    test('downloads zip, extracts, generates update script, and runs it', () async {
      final tempDir = Directory.systemTemp.createTempSync('updater_test_desktop_');
      final appDir = Directory.systemTemp.createTempSync('app_dir_test_');
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
        if (appDir.existsSync()) appDir.deleteSync(recursive: true);
      });

      // Prepare a dummy zip archive with an executable
      final archive = Archive();
      final fileData = utf8.encode('new binary content');
      archive.addFile(ArchiveFile('clinical_companion', fileData.length, fileData));
      final zipBytes = ZipEncoder().encode(archive);

      final client = MockClient((request) async {
        return http.Response.bytes(zipBytes, 200, headers: {'content-length': '${zipBytes.length}'});
      });

      final service = AppUpdaterService(httpClient: client);

      String? executedCommand;
      List<String>? executedArgs;
      int? exitCodePassed;

      await service.downloadAndApplyDesktopUpdate(
        downloadUrl: 'https://example.com/update.zip',
        customTempDir: tempDir,
        currentAppDirectory: appDir.path,
        currentExecutablePath: '${appDir.path}/clinical_companion',
        processRunner: (command, args) async {
          executedCommand = command;
          executedArgs = args;
          return ProcessResult(1234, 0, 'success', '');
        },
        appExiter: (code) {
          exitCodePassed = code;
        },
      );

      expect(executedCommand, isNotNull);
      expect(executedArgs, isNotNull);
      expect(exitCodePassed, 0);

      // Verify that the extracted files exist
      final extracted = File('${tempDir.path}/extracted/clinical_companion');
      expect(extracted.existsSync(), isTrue);

      // Verify update script exists
      if (Platform.isWindows) {
        final script = File('${tempDir.path}/update.bat');
        expect(script.existsSync(), isTrue);
      } else {
        final script = File('${tempDir.path}/update.sh');
        expect(script.existsSync(), isTrue);
      }
    });
  });
}

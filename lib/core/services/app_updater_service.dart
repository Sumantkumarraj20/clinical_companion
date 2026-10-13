import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.apkUrl,
    required this.releaseUrl,
    required this.remoteVersion,
    required this.localVersion,
    this.zipUrl,
    this.platformAssetUrl,
  });

  final String apkUrl;
  final String releaseUrl;
  final String remoteVersion;
  final String localVersion;
  final String? zipUrl;
  final String? platformAssetUrl;

  /// Returns the appropriate asset download URL for the current platform.
  String get downloadUrl => platformAssetUrl ?? zipUrl ?? apkUrl;
}

class UpdateAvailable extends AppUpdateInfo {
  const UpdateAvailable({
    required super.apkUrl,
    required super.releaseUrl,
    required super.remoteVersion,
    required super.localVersion,
    super.zipUrl,
    super.platformAssetUrl,
  });
}

/// Sprint 8 — CI/CD & In-App Binary Updates: GitHub Release update probe.
///
/// Asks GitHub for the newest published Release (created by
/// `.github/workflows/build_release.yml` when a `v*` tag is pushed) and
/// compares its `tag_name` (e.g. `v1.0.5`) against the version baked into
/// this binary by `pubspec.yaml`. When the release is strictly newer, the
/// `browser_download_url` of its APK asset and the release page URL are
/// returned. Android downloads the APK and submits it to the native installer;
/// desktop platforms open the release page in the system browser. Because the
/// package name and signing key are unchanged, Android preserves the app data
/// sandbox (Drift and clinical records) during an in-place upgrade.
///
/// The check is deliberately fail-soft: any transport error, timeout,
/// non-200 status (e.g. GitHub rate limiting) or malformed payload logs a
/// single debug line and resolves to `null`, so an offline clinician never
/// sees an error and the dashboard never blocks on the network.
class AppUpdaterService {
  AppUpdaterService({
    http.Client? httpClient,
    Future<PackageInfo> Function()? packageInfoLoader,
    this.releasesUrl = defaultReleasesUrl,
    this.requestTimeout = const Duration(seconds: 15),
  }) : _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _packageInfoLoader = packageInfoLoader ?? PackageInfo.fromPlatform;

  /// `GET /releases/latest` endpoint for this repository. Unauthenticated
  /// GitHub API allows 60 requests/hour per IP — plenty for a
  /// once-per-session dashboard check.
  static const String defaultReleasesUrl =
      'https://api.github.com/repos/Sumantkumarraj20/clinical_companion/releases/latest';

  final http.Client _client;
  final bool _ownsClient;
  final Future<PackageInfo> Function() _packageInfoLoader;

  /// Overridable endpoint (tests / forks).
  final String releasesUrl;

  final Duration requestTimeout;

  /// Returns the direct APK download URL of the latest GitHub release when
  /// it is newer than the installed [PackageInfo.version]; otherwise `null`.
  ///
  /// `null` means "no update offered" for *any* reason — up-to-date install,
  /// no `.apk` asset attached, or any network/parse failure. This method
  /// never throws so it is safe to call from a `FutureProvider` at startup.
  Future<String?> checkForUpdate() async {
    return (await checkForUpdates())?.apkUrl;
  }

  /// Returns update details for UI surfaces that need to show the version
  /// change, or `null` when no update is available.
  Future<AppUpdateInfo?> checkForUpdateInfo() => checkForUpdates();

  /// Checks GitHub's latest published Release for a newer APK release.
  Future<UpdateAvailable?> checkForUpdates() async {
    try {
      final info = await _packageInfoLoader();

      final response = await _client
          .get(
            Uri.parse(releasesUrl),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'X-GitHub-Api-Version': '2022-11-28',
            },
          )
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        debugPrint(
          '[AppUpdater] Release fetch failed '
          '(HTTP ${response.statusCode}) — skipping.',
        );
        return null;
      }

      final dynamic payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        debugPrint('[AppUpdater] Unexpected release payload — skipping.');
        return null;
      }

      final tagName = payload['tag_name'];
      if (tagName is! String || tagName.isEmpty) return null;

      if (!isRemoteNewer(info.version, tagName)) {
        debugPrint(
          '[AppUpdater] Installed ${info.version} is up to date '
          '(latest release: $tagName).',
        );
        return null;
      }

      final releasePage = payload['html_url'];
      final releaseUrl = releasePage is String && releasePage.isNotEmpty
          ? releasePage
          : 'https://github.com/Sumantkumarraj20/clinical_companion/'
                'releases/tag/${Uri.encodeComponent(tagName)}';
      final assets = payload['assets'];
      if (assets is! List) return null;

      String? apkUrl;
      String? windowsZipUrl;
      String? linuxZipUrl;

      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name'] as String?;
        final url = asset['browser_download_url'] as String?;
        if (name == null || url == null || url.isEmpty) continue;

        if (name == 'app-release.apk') {
          apkUrl = url;
        } else if (name == 'clinical-companion-windows.zip') {
          windowsZipUrl = url;
        } else if (name == 'clinical-companion-linux.zip') {
          linuxZipUrl = url;
        }
      }

      String? targetPlatformZipUrl;
      if (!kIsWeb) {
        if (Platform.isWindows) {
          targetPlatformZipUrl = windowsZipUrl;
        } else if (Platform.isLinux) {
          targetPlatformZipUrl = linuxZipUrl;
        }
      }

      final chosenUrl = targetPlatformZipUrl ?? apkUrl;
      if (chosenUrl == null || chosenUrl.isEmpty) {
        debugPrint('[AppUpdater] $tagName is newer but has no matching release asset.');
        return null;
      }

      // Cache busting: append timestamp parameter to force fresh binary download
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String bustCache(String raw) =>
          raw.contains('?') ? '$raw&t=$timestamp' : '$raw?t=$timestamp';

      final bustedApkUrl = apkUrl != null ? bustCache(apkUrl) : bustCache(chosenUrl);
      final bustedZipUrl =
          targetPlatformZipUrl != null ? bustCache(targetPlatformZipUrl) : null;

      debugPrint('[AppUpdater] Update $tagName available: $chosenUrl');
      return UpdateAvailable(
        apkUrl: bustedApkUrl,
        zipUrl: bustedZipUrl,
        platformAssetUrl: bustedZipUrl,
        releaseUrl: releaseUrl,
        remoteVersion: _displayVersion(tagName),
        localVersion: _displayVersion(info.version),
      );
    } catch (error) {
      // Offline, DNS failure, timeout, malformed JSON … all fail silently
      // so the update check never blocks or alarms the clinician.
      debugPrint('[AppUpdater] Update check skipped: $error');
      return null;
    }
  }

  /// Explicitly clears old update files before download to avoid stale cache bugs.
  Future<void> clearOldUpdateFiles([Directory? targetDirectory]) async {
    try {
      final dir = targetDirectory ?? await getApplicationSupportDirectory();
      final otaDir = Directory(p.join(dir.path, 'ota'));
      if (otaDir.existsSync()) {
        final apk = File(p.join(otaDir.path, 'app-release.apk'));
        if (apk.existsSync()) {
          apk.deleteSync();
        }
        final updateApk = File(p.join(otaDir.path, 'update.apk'));
        if (updateApk.existsSync()) {
          updateApk.deleteSync();
        }
      }
      final rootApk = File(p.join(dir.path, 'app-release.apk'));
      if (rootApk.existsSync()) {
        rootApk.deleteSync();
      }
    } catch (e) {
      debugPrint('[AppUpdater] Could not clear old update files: $e');
    }
  }

  /// Downloads a ZIP release for desktop (Windows or Linux), extracts it, writes
  /// a self-updating script, executes it via [Process.run], and terminates the app.
  Future<void> downloadAndApplyDesktopUpdate({
    required String downloadUrl,
    void Function(double progress)? onProgress,
    void Function(int receivedBytes, int totalBytes)? onBytes,
    Future<ProcessResult> Function(String executable, List<String> arguments)? processRunner,
    void Function(int code)? appExiter,
    Directory? customTempDir,
    String? currentAppDirectory,
    String? currentExecutablePath,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError('Desktop auto-update is not supported on web.');
    }

    onProgress?.call(0.0);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final bustedUrl = downloadUrl.contains('?')
        ? '$downloadUrl&t=$timestamp'
        : '$downloadUrl?t=$timestamp';

    final tempDir = customTempDir ??
        await Directory.systemTemp.createTemp('clincom_desktop_update_');
    final zipFile = File(p.join(tempDir.path, 'update.zip'));
    if (zipFile.existsSync()) {
      try {
        zipFile.deleteSync();
      } catch (_) {}
    }

    // 1. Download the ZIP file
    final request = http.Request('GET', Uri.parse(bustedUrl));
    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode != 200) {
      throw StateError(
        'Failed to download update: HTTP ${streamedResponse.statusCode}',
      );
    }

    final totalBytes = streamedResponse.contentLength ?? 0;
    var receivedBytes = 0;
    final sink = zipFile.openWrite();

    await for (final chunk in streamedResponse.stream) {
      sink.add(chunk);
      receivedBytes += chunk.length;
      if (totalBytes > 0) {
        onProgress?.call((receivedBytes / totalBytes).clamp(0.0, 1.0));
      }
      onBytes?.call(receivedBytes, totalBytes);
    }
    await sink.flush();
    await sink.close();

    onProgress?.call(1.0);

    // 2. Unzip using the archive package to a temporary directory
    final extractDir = Directory(p.join(tempDir.path, 'extracted'));
    if (!extractDir.existsSync()) {
      extractDir.createSync(recursive: true);
    }

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    extractArchiveToDiskSync(archive, extractDir.path);

    var sourceDir = extractDir.path;
    final entities = extractDir.listSync();
    if (entities.length == 1 && entities.first is Directory) {
      sourceDir = entities.first.path;
    }

    final appDir = currentAppDirectory ?? File(Platform.resolvedExecutable).parent.path;
    final exePath = currentExecutablePath ?? Platform.resolvedExecutable;
    final exeName = p.basename(exePath);
    final currentPid = pid;

    final runner = processRunner ?? Process.run;
    final exiter = appExiter ?? exit;

    if (Platform.isWindows) {
      final scriptFile = File(p.join(tempDir.path, 'update.bat'));
      final targetExePath = p.join(appDir, exeName);
      final batContent = '''@echo off
timeout /t 3 /nobreak > nul
taskkill /F /PID $currentPid > nul 2>&1
taskkill /F /IM "$exeName" > nul 2>&1
taskkill /F /IM "clincom.exe" > nul 2>&1
taskkill /F /IM "clinical_companion.exe" > nul 2>&1
xcopy /s /e /y /q "$sourceDir\\*" "$appDir\\"
start "" "$targetExePath"
rd /s /q "$tempDir"
(goto) 2>nul & del "%~f0"
''';
      await scriptFile.writeAsString(batContent);

      unawaited(runner('cmd.exe', ['/c', 'start', '""', scriptFile.path]));
    } else {
      final scriptFile = File(p.join(tempDir.path, 'update.sh'));
      final targetExePath = p.join(appDir, exeName);
      final shContent = '''#!/usr/bin/env bash
sleep 3
kill -9 $currentPid 2>/dev/null || true
pkill -9 -f "$exeName" 2>/dev/null || true
pkill -9 -f "clinical_companion" 2>/dev/null || true
pkill -9 -f "clincom" 2>/dev/null || true
cp -a "$sourceDir"/. "$appDir"/
chmod +x "$targetExePath"
nohup "$targetExePath" >/dev/null 2>&1 &
rm -rf "$tempDir"
rm -f "\$0"
''';
      await scriptFile.writeAsString(shContent);
      try {
        await Process.run('chmod', ['+x', scriptFile.path]);
      } catch (_) {}

      unawaited(runner('bash', [scriptFile.path]));
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    exiter(0);
  }

  /// True when [tagOrVersion] (e.g. `v1.0.5`) denotes a strictly higher
  /// version than [localVersion] (e.g. `1.0.0`).
  /// Compares the installed build against the published tag using real SemVer
  /// precedence (`pub_semver`), not a hand-rolled segment split.
  ///
  /// This matters in two ways the old numeric comparison got wrong:
  ///  * `1.0.10` correctly outranks `1.0.9` (both are fine numerically, but the
  ///    old code returned `false` for equal-length comparisons it mis-ordered);
  ///  * a pre-release tag like `v1.1.0-beta.1` sorts BELOW `v1.1.0`, so testers
  ///    on a release build are not pushed onto a pre-release.
  ///
  /// The banner is driven by "is the remote strictly newer?", so equal or
  /// older remote versions return `false` and `checkForUpdate` yields `null`,
  /// destroying the banner. Unparseable input fails closed (no update) rather
  /// than nagging the clinician about a tag format we do not understand.
  @visibleForTesting
  static bool isRemoteNewer(String localVersion, String tagOrVersion) {
    final local = _parseVersion(localVersion);
    final remote = _parseVersion(tagOrVersion);
    if (local == null || remote == null) return false;
    return remote > local;
  }

  static String _displayVersion(String raw) =>
      raw.trim().replaceFirst(RegExp(r'^[vV]'), '');

  /// Parses a GitHub tag (`v1.2.3`, `1.2`, `1.2.3-beta.1+build5`) into a
  /// [Version]. Returns null when the string is not a recognisable version.
  static Version? _parseVersion(String raw) {
    var candidate = raw.trim();
    if (candidate.isEmpty) return null;
    // Tags are conventionally prefixed with `v`.
    candidate = candidate.replaceFirst(RegExp(r'^[vV]'), '');
    // `Version.parse` accepts only the version core, so drop any build
    // metadata; pre-release suffixes (`-beta.1`) are kept and honoured.
    candidate = candidate.split('+').first;

    // Split the pre-release off so the numeric core can be zero-padded.
    final dash = candidate.indexOf('-');
    final core = dash == -1 ? candidate : candidate.substring(0, dash);
    final preRelease = dash == -1 ? '' : candidate.substring(dash);

    final parts = core.split('.');
    if (parts.isEmpty || parts.length > 3) return null;
    for (final part in parts) {
      if (int.tryParse(part.trim()) == null) return null;
    }
    // Strict SemVer requires three components; Android/`pubspec` versions like
    // `1.0` and `1` are common in the wild, so pad them rather than failing
    // closed — otherwise a clinician on `1.0.3` would be prompted forever
    // because `1.0` could never be parsed.
    final padded = [
      ...parts.map((p) => p.trim()),
      ...List.filled(3 - parts.length, '0'),
    ].join('.');

    try {
      return Version.parse('$padded$preRelease');
    } on FormatException {
      return null;
    }
  }

  /// Only closes the HTTP client when this service created it itself; a
  /// client injected from Riverpod is disposed by its own provider.
  void dispose() {
    if (_ownsClient) _client.close();
  }
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Sprint 8 — CI/CD & In-App Binary Updates: GitHub Release update probe.
///
/// Asks GitHub for the newest published Release (created by
/// `.github/workflows/build_release.yml` when a `v*` tag is pushed) and
/// compares its `tag_name` (e.g. `v1.0.5`) against the version baked into
/// this binary by `pubspec.yaml`. When the release is strictly newer, the
/// `browser_download_url` of its APK asset is returned so the UI can hand
/// it to `url_launcher` with `LaunchMode.externalApplication` — Android's
/// browser/OS then performs an in-place upgrade. Because the package name
/// and signing key are unchanged, the `/data/data` SQLite sandbox (Drift,
/// all patient data) is preserved by the platform during the install.
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

      final assets = payload['assets'];
      if (assets is! List) return null;
      for (final asset in assets) {
        if (asset is! Map<String, dynamic>) continue;
        final name = asset['name'];
        if (name is! String || !name.toLowerCase().endsWith('.apk')) {
          continue;
        }
        final downloadUrl = asset['browser_download_url'];
        if (downloadUrl is String && downloadUrl.isNotEmpty) {
          debugPrint('[AppUpdater] Update $tagName available: $downloadUrl');
          return downloadUrl;
        }
      }

      debugPrint('[AppUpdater] $tagName is newer but has no APK asset.');
      return null;
    } catch (error) {
      // Offline, DNS failure, timeout, malformed JSON … all fail silently
      // so the update check never blocks or alarms the clinician.
      debugPrint('[AppUpdater] Update check skipped: $error');
      return null;
    }
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

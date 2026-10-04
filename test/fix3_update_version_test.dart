import 'package:clinical_companion/core/services/app_updater_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// FIX 3 — the update banner must disappear once the installed build is at or
/// ahead of the published GitHub release. `isRemoteNewer` is the single gate
/// that decides this, so it is pinned here including the leading-`v` case.
void main() {
  test('identical versions are not newer, so the banner stays hidden', () {
    expect(AppUpdaterService.isRemoteNewer('1.0.3', '1.0.3'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.3', 'v1.0.3'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.3', 'V1.0.3'), isFalse);
  });

  test('a local build ahead of the release hides the banner', () {
    expect(AppUpdaterService.isRemoteNewer('1.0.4', 'v1.0.3'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('2.0.0', '1.9.9'), isFalse);
  });

  test('a genuinely newer release still prompts', () {
    expect(AppUpdaterService.isRemoteNewer('1.0.3', 'v1.0.4'), isTrue);
    expect(AppUpdaterService.isRemoteNewer('1.9.9', '2.0.0'), isTrue);
  });

  test('segment-wise comparison, not lexicographic', () {
    // '1.10.0' must beat '1.9.0' — a string compare would get this backwards.
    expect(AppUpdaterService.isRemoteNewer('1.9.0', 'v1.10.0'), isTrue);
    expect(AppUpdaterService.isRemoteNewer('1.10.0', 'v1.9.0'), isFalse);
  });

  test('unparseable input fails closed (no spurious update prompt)', () {
    expect(AppUpdaterService.isRemoteNewer('', 'v1.0.3'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.3', ''), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.3', 'latest'), isFalse);
  });

  // Sprint 14.5 — real SemVer precedence via pub_semver.
  test('multi-digit segments order numerically, not lexicographically', () {
    expect(AppUpdaterService.isRemoteNewer('1.0.9', 'v1.0.10'), isTrue);
    expect(AppUpdaterService.isRemoteNewer('1.0.10', 'v1.0.9'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.9.0', 'v1.10.0'), isTrue);
  });

  test('a pre-release tag sorts BELOW its release', () {
    // A clinician already on 1.1.0 must not be pushed onto 1.1.0-beta.1.
    expect(AppUpdaterService.isRemoteNewer('1.1.0', 'v1.1.0-beta.1'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.0', 'v1.1.0-beta.1'), isTrue);
  });

  test('build metadata does not affect precedence', () {
    expect(AppUpdaterService.isRemoteNewer('1.0.3', 'v1.0.3+build9'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.3+build9', 'v1.0.3'), isFalse);
  });

  test('shorter and longer version shapes compare correctly', () {
    expect(AppUpdaterService.isRemoteNewer('1.0', 'v1.0.1'), isTrue);
    expect(AppUpdaterService.isRemoteNewer('1.0.1', 'v1.0'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.0', 'v1.0'), isFalse);
  });

  test('an equal or newer local build yields false, destroying the banner', () {
    // The reported bug: the banner persisted after installing the update.
    expect(AppUpdaterService.isRemoteNewer('1.0.3', '1.0.3'), isFalse);
    expect(AppUpdaterService.isRemoteNewer('1.0.4', '1.0.3'), isFalse);
  });
}

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
}

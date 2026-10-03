import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Why an in-app update failed. Every value carries a message the UI can show
/// verbatim, because an update failure is never something a clinician can fix.
enum InAppUpdateErrorKind {
  /// Device is offline, DNS failure, socket reset, TLS problem.
  network,

  /// The server answered, but not with an APK.
  http,

  /// The APK arrived but is not a readable file (truncated / HTML error page).
  corrupt,

  /// Android refused to hand the APK to the package installer.
  install,
}

/// Failure of [InAppUpdateManager.downloadAndInstall].
class InAppUpdateException implements Exception {
  const InAppUpdateException(this.kind, this.message, {this.cause});

  final InAppUpdateErrorKind kind;
  final String message;
  final Object? cause;

  @override
  String toString() => 'InAppUpdateException(${kind.name}): $message';
}

/// Downloads a release APK inside the app and hands it to Android's package
/// installer.
///
/// **Why in-app rather than a browser.** A clinician on a weak connection
/// should see real progress instead of a blank browser tab, and — more
/// importantly — an interrupted browser download loses everything. Here a
/// failure is reported, the partial file is deleted, and the update can simply
/// be retried.
///
/// **Data safety.** The install is an in-place upgrade: same package name and
/// same signing key means Android preserves `/data/data/<pkg>` and therefore the
/// Drift/SQLite clinical record. A *differently signed* APK is rejected by the
/// platform, so the release workflow must sign every APK with the upload key.
class InAppUpdateManager {
  InAppUpdateManager({
    Dio? dio,
    Future<Directory> Function()? directoryProvider,
    Future<OpenResult> Function(String path)? opener,
    this.fileName = 'update.apk',
  })  : _dio = dio ?? Dio(),
        _directoryProvider = directoryProvider ?? getTemporaryDirectory,
        _opener = opener ?? OpenFilex.open;

  final Dio _dio;
  final Future<Directory> Function() _directoryProvider;
  final Future<OpenResult> Function(String path) _opener;

  /// Name of the downloaded APK inside the cache directory.
  final String fileName;

  CancelToken? _cancelToken;

  /// Cancels an in-flight download. Safe to call when nothing is running.
  void cancel() {
    _cancelToken?.cancel('cancelled by user');
    _cancelToken = null;
  }

  /// Downloads [apkUrl] and opens it with the platform installer.
  ///
  /// [onProgress] receives a 0.0–1.0 fraction. It is called with 0.0 before
  /// the transfer starts and exactly 1.0 once the bytes are on disk, so a UI
  /// never sits at a stale percentage while the installer is being launched.
  ///
  /// Throws [InAppUpdateException] on any failure; it never throws anything
  /// else, so callers need exactly one catch.
  Future<void> downloadAndInstall({
    required String apkUrl,
    required void Function(double progress) onProgress,
    void Function(int receivedBytes, int totalBytes)? onBytes,
  }) async {
    final uri = Uri.tryParse(apkUrl);
    if (uri == null || !uri.isAbsolute || uri.scheme.isEmpty) {
      throw const InAppUpdateException(
        InAppUpdateErrorKind.http,
        'The update link is not a valid URL.',
      );
    }

    final directory = await _directoryProvider();
    final savePath = p.join(directory.path, fileName);

    // A previous attempt may have left a truncated APK. Removing it first
    // means we can never "install" a half-written file.
    final target = File(savePath);
    if (target.existsSync()) {
      try {
        target.deleteSync();
      } catch (error) {
        throw InAppUpdateException(
          InAppUpdateErrorKind.corrupt,
          'Could not clear the previous update download.',
          cause: error,
        );
      }
    }

    onProgress(0);

    _cancelToken = CancelToken();
    try {
      await _dio.download(
        apkUrl,
        savePath,
        cancelToken: _cancelToken,
        // A corrupt transfer must never survive: deleteOnError removes the
        // partial file so a later retry starts clean.
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          // GitHub release assets always send Content-Length; when they do
          // not, stay indeterminate rather than reporting a bogus fraction.
          if (total > 0) {
            onProgress((received / total).clamp(0.0, 1.0));
            onBytes?.call(received, total);
          }
        },
      );

      final downloaded = File(savePath);
      if (!downloaded.existsSync() || downloaded.lengthSync() == 0) {
        throw const InAppUpdateException(
          InAppUpdateErrorKind.corrupt,
          'The update file was empty after download.',
        );
      }

      onProgress(1);

      final result = await _opener(savePath);
      if (result.type != ResultType.done) {
        throw InAppUpdateException(
          InAppUpdateErrorKind.install,
          'Android could not open the installer. You may need to allow '
              '"Install unknown apps" for Clinical Companion.',
          cause: result.message,
        );
      }
    } on DioException catch (error) {
      _deleteQuietly(savePath);
      throw mapDioError(error);
    } on InAppUpdateException {
      _deleteQuietly(savePath);
      rethrow;
    } catch (error) {
      _deleteQuietly(savePath);
      throw InAppUpdateException(
        InAppUpdateErrorKind.install,
        'The update could not be installed.',
        cause: error,
      );
    } finally {
      _cancelToken = null;
    }
  }

  /// Removes a partial download.
  ///
  /// Dio's `deleteOnError` is not relied upon here: it does not fire for every
  /// failure mode (a CancelToken abort, for one), and a truncated APK left on
  /// disk is exactly the kind of file that later gets "installed" and fails
  /// confusingly. Belt and braces, because the cost is one failed unlink.
  void _deleteQuietly(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (error) {
      debugPrint('[InAppUpdate] Could not remove partial download: $error');
    }
  }

  /// Deletes a downloaded APK. Useful to reclaim space after a failure.
  Future<void> cleanup() async {
    try {
      final directory = await _directoryProvider();
      final file = File(p.join(directory.path, fileName));
      if (file.existsSync()) await file.delete();
    } catch (error) {
      debugPrint('[InAppUpdate] Cleanup skipped: $error');
    }
  }
}

/// Exposes the Dio → [InAppUpdateException] mapping so error classification
/// can be asserted directly, without standing up a failing server.
@visibleForTesting
InAppUpdateException toExceptionForTesting(DioException error) =>
    mapDioError(error);

/// Classifies a transport failure into an actionable, user-facing message.
InAppUpdateException mapDioError(DioException error) {
    final status = error.response?.statusCode;
    if (status != null) {
      return InAppUpdateException(
        InAppUpdateErrorKind.http,
        'The server returned HTTP $status instead of an APK.',
        cause: error,
      );
    }
    if (error.type == DioExceptionType.cancel) {
      return const InAppUpdateException(
        InAppUpdateErrorKind.network,
        'The update download was cancelled.',
      );
    }
    return InAppUpdateException(
      InAppUpdateErrorKind.network,
      'Could not reach the update server. Check your connection and try again.',
      cause: error,
    );
  }

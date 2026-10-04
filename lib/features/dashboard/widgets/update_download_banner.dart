import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/in_app_update_manager.dart';

/// Lifecycle of a background in-app update download.
///
/// Sprint 14.5 — this used to be a non-dismissible modal sheet that blocked the
/// clinician from doing anything else for the whole download. The state now
/// lives in a provider so the dashboard renders it inline while the user keeps
/// working.
sealed class UpdateDownloadState {
  const UpdateDownloadState();
}

class UpdateIdle extends UpdateDownloadState {
  const UpdateIdle();
}

class UpdateDownloading extends UpdateDownloadState {
  const UpdateDownloading({
    required this.progress,
    required this.receivedBytes,
    required this.totalBytes,
  });

  /// 0.0–1.0, or null when the server sent no Content-Length and the true
  /// fraction is genuinely unknown.
  final double? progress;
  final int receivedBytes;
  final int totalBytes;

  UpdateDownloading copyWith({
    double? progress,
    int? receivedBytes,
    int? totalBytes,
  }) {
    return UpdateDownloading(
      progress: progress ?? this.progress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
    );
  }
}

/// Download reached 100% and the Android installer intent has already fired.
class UpdateInstalling extends UpdateDownloadState {
  const UpdateInstalling();
}

class UpdateFailed extends UpdateDownloadState {
  const UpdateFailed(this.message, {this.cancelled = false});

  final String message;
  final bool cancelled;
}

/// Owns the in-app update download app-wide.
///
/// Deliberately global rather than banner-local: the download must survive the
/// clinician navigating away from the dashboard, which is the whole point of
/// making it non-blocking.
final updateDownloadProvider =
    NotifierProvider<UpdateDownloadNotifier, UpdateDownloadState>(
      UpdateDownloadNotifier.new,
    );

class UpdateDownloadNotifier extends Notifier<UpdateDownloadState> {
  final InAppUpdateManager _manager = InAppUpdateManager();

  @override
  UpdateDownloadState build() {
    // Riverpod's Notifier has no dispose(); registering here guarantees the
    // transfer is cancelled when the provider is torn down, so an orphaned
    // download can never keep running in the background.
    ref.onDispose(_manager.cancel);
    return const UpdateIdle();
  }

  bool get isBusy => state is UpdateDownloading || state is UpdateInstalling;

  /// Starts or restarts the download. A second tap while one is already
  /// running is ignored rather than starting a parallel transfer over a ward's
  /// metered connection.
  Future<void> start(String apkUrl) async {
    if (state is UpdateDownloading) return;

    state = const UpdateDownloading(
      progress: 0,
      receivedBytes: 0,
      totalBytes: 0,
    );
    try {
      await _manager.downloadAndInstall(
        apkUrl: apkUrl,
        onProgress: (value) {
          final current = state;
          if (current is UpdateDownloading) {
            state = current.copyWith(progress: value);
          }
        },
        onBytes: (received, total) {
          final current = state;
          if (current is UpdateDownloading) {
            state = current.copyWith(
              receivedBytes: received,
              totalBytes: total,
            );
          }
        },
      );
      // Success means 100% reached AND the installer intent already fired.
      state = const UpdateInstalling();
    } on InAppUpdateException catch (error) {
      state = UpdateFailed(
        error.message,
        cancelled: error.message.toLowerCase().contains('cancel'),
      );
    } catch (error) {
      state = UpdateFailed('The update could not be started: $error');
    }
  }

  void cancel() {
    _manager.cancel();
    state = const UpdateIdle();
  }

  /// Clears a terminal state so the banner can disappear on its own.
  void acknowledge() {
    if (state is UpdateFailed || state is UpdateInstalling) {
      state = const UpdateIdle();
    }
  }
}

String formatUpdateBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}

/// Inline, non-blocking update progress.
///
/// Rendered inside the dashboard so the app stays fully usable during the
/// download — the clinician keeps opening patients and writing notes.
class UpdateProgressBanner extends ConsumerWidget {
  const UpdateProgressBanner({required this.apkUrl, super.key});

  final String apkUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateDownloadProvider);
    final colors = Theme.of(context).colorScheme;

    return switch (state) {
      UpdateIdle() => const SizedBox.shrink(),
      UpdateFailed(:final message, :final cancelled) => MaterialBanner(
        backgroundColor: colors.errorContainer,
        leading: Icon(
          cancelled ? Icons.cancel_outlined : Icons.error_outline,
          color: colors.onErrorContainer,
        ),
        content: Text(
          cancelled ? 'Update download cancelled.' : message,
          style: TextStyle(color: colors.onErrorContainer),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(updateDownloadProvider.notifier).acknowledge(),
            child: Text(
              'Dismiss',
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
          TextButton(
            onPressed: () =>
                ref.read(updateDownloadProvider.notifier).start(apkUrl),
            child: Text(
              'Retry',
              style: TextStyle(color: colors.onErrorContainer),
            ),
          ),
        ],
      ),
      UpdateInstalling() => MaterialBanner(
        backgroundColor: colors.tertiaryContainer,
        leading: Icon(
          Icons.install_mobile_outlined,
          color: colors.onTertiaryContainer,
        ),
        content: Text(
          'Download complete. Opening the Android installer…',
          style: TextStyle(color: colors.onTertiaryContainer),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(updateDownloadProvider.notifier).acknowledge(),
            child: Text(
              'OK',
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
        ],
      ),
      UpdateDownloading(
        :final progress,
        :final receivedBytes,
        :final totalBytes,
      ) =>
        MaterialBanner(
          backgroundColor: colors.secondaryContainer,
          leading: Icon(
            Icons.system_update,
            color: colors.onSecondaryContainer,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Downloading update in the background — you can keep working.',
                style: TextStyle(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  // A null value renders the indeterminate bar, which is the
                  // honest state while Content-Length is unknown.
                  value: (totalBytes <= 0 && progress == 0) ? null : progress,
                  minHeight: 6,
                  color: colors.onSecondaryContainer,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                totalBytes > 0
                    ? '${formatUpdateBytes(receivedBytes)} of '
                          '${formatUpdateBytes(totalBytes)} · '
                          '${((progress ?? 0) * 100).round()}%'
                    : 'Downloading… ${formatUpdateBytes(receivedBytes)}',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSecondaryContainer,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  ref.read(updateDownloadProvider.notifier).cancel(),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.onSecondaryContainer),
              ),
            ),
          ],
        ),
    };
  }
}

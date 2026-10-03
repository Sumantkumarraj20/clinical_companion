import 'package:flutter/material.dart';

import '../../../core/services/in_app_update_manager.dart';

/// Opens the in-app update progress sheet.
///
/// Separate from the banner so the download survives the banner being
/// dismissed and can be re-triggered from elsewhere later.
Future<void> showInAppUpdateSheet(BuildContext context, String apkUrl) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    // Draining the sheet would leave an orphaned download with no way to
    // cancel it, so the sheet owns its own lifecycle.
    enableDrag: false,
    builder: (sheetContext) => _UpdateProgressSheet(apkUrl: apkUrl),
  );
}

/// Live download progress for an in-app update.
///
/// Shows the phases distinctly rather than one bare bar, because the risky
/// moment for a clinician is *after* the download — when Android decides
/// whether the install is allowed. Silently swapping a 100% bar for the
/// system installer leaves people unsure whether to tap.
class _UpdateProgressSheet extends StatefulWidget {
  const _UpdateProgressSheet({required this.apkUrl});

  final String apkUrl;

  @override
  State<_UpdateProgressSheet> createState() => _UpdateProgressSheetState();
}

enum _UpdatePhase { downloading, launching, failed }

class _UpdateProgressSheetState extends State<_UpdateProgressSheet> {
  final _manager = InAppUpdateManager();

  double _progress = 0;
  int _received = 0;
  int _total = 0;
  _UpdatePhase _phase = _UpdatePhase.downloading;
  String? _error;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    // Leaving the sheet mid-flight must not leave a download running.
    _manager.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _phase = _UpdatePhase.downloading;
      _progress = 0;
      _received = 0;
      _total = 0;
      _error = null;
      _cancelled = false;
    });

    try {
      await _manager.downloadAndInstall(
        apkUrl: widget.apkUrl,
        onProgress: (value) {
          if (!mounted) return;
          setState(() => _progress = value);
        },
        onBytes: (received, total) {
          if (!mounted) return;
          setState(() {
            _received = received;
            _total = total;
          });
        },
      );
      // Success means the installer intent was fired. Close so Android's
      // package installer is drawn unobstructed on top of the Flutter view.
      if (mounted) {
        setState(() => _phase = _UpdatePhase.launching);
        Navigator.of(context).maybePop();
      }
    } on InAppUpdateException catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _UpdatePhase.failed;
        _error = error.message;
        _cancelled = error.message.toLowerCase().contains('cancel');
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _phase = _UpdatePhase.failed;
        _error = 'The update could not be started: $error';
      });
    }
  }

  String get _headline => switch (_phase) {
    _UpdatePhase.downloading => 'Downloading Update…',
    _UpdatePhase.launching => 'Opening installer…',
    _UpdatePhase.failed => _cancelled ? 'Download cancelled' : 'Update failed',
  };

  String get _body => switch (_phase) {
    _UpdatePhase.downloading =>
      'Keep the app open. Your patient data stays on this device.',
    _UpdatePhase.launching =>
      'Android is opening the package installer. Tap "Install" to finish — '
          'your records will be preserved.',
    _UpdatePhase.failed => _error ?? 'Something went wrong.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFailed = _phase == _UpdatePhase.failed;
    final isDone = _phase == _UpdatePhase.launching;
    final color = isFailed
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final percent = (_progress * 100).clamp(0, 100).round();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFailed ? Icons.error_outline : Icons.system_update,
                  color: color,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _headline,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isFailed)
                  Text(
                    isDone ? '100%' : '$percent%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _body,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            if (isFailed)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _start,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
                ],
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  // `value == null` renders the indeterminate bar, which is
                  // the honest state while Content-Length is unknown.
                  value: _total <= 0 && _progress == 0 ? null : _progress,
                  minHeight: 8,
                  color: color,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _total > 0 ? _formatBytes(_received) : 'Starting…',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Text(
                    _total > 0 ? 'of ${_formatBytes(_total)}' : '',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _cancelled = true;
                  _manager.cancel();
                },
                child: const Text('Cancel'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final mb = bytes / (1024 * 1024);
    if (mb < 1) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${mb.toStringAsFixed(1)} MB';
  }
}

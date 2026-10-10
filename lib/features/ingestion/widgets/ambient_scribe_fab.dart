import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/local_database.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/ambient_scribe_service.dart';

class AmbientScribeFab extends ConsumerStatefulWidget {
  const AmbientScribeFab({this.patient, super.key});

  final Patient? patient;

  @override
  ConsumerState<AmbientScribeFab> createState() => _AmbientScribeFabState();
}

class _AmbientScribeFabState extends ConsumerState<AmbientScribeFab>
    with SingleTickerProviderStateMixin {
  late final AmbientScribeService _scribe;
  late final AnimationController _pulse;
  bool _processing = false;
  String _localeId = AmbientScribeService.defaultLocaleId;

  @override
  void initState() {
    super.initState();
    _scribe = ref.read(ambientScribeServiceProvider);
    _scribe.state.addListener(_handleScribeState);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _scribe.state.removeListener(_handleScribeState);
    _pulse.dispose();
    super.dispose();
  }

  void _handleScribeState() {
    if (!mounted) return;
    final status = _scribe.state.value.status;
    if (status == AmbientScribeStatus.recording) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 0;
    }
    setState(() {});
  }

  Future<void> _toggleScribe() async {
    final status = _scribe.state.value.status;
    if (status == AmbientScribeStatus.idle) {
      try {
        await _scribe.startListening(localeId: _localeId);
      } catch (error) {
        _showError('Could not start recording: $error');
      }
      return;
    }
    if (status == AmbientScribeStatus.transcribing || _processing) return;

    setState(() => _processing = true);
    try {
      final transcript = await _scribe.stopAndGetTranscript();
      final dao = ref.read(clinicalDaoProvider);
      final census = await BatchExtractionNotifier.buildActiveCensusJson(dao);
      ref
          .read(batchExtractionProvider.notifier)
          .addOmniText(
            transcript,
            activeCensusJson: census,
            isAmbientAudio: true,
          );
      if (!mounted) return;
      setState(() => _processing = false);
      unawaited(context.push<void>('/adaptive-review', extra: widget.patient));
    } catch (error) {
      _showError('Could not transcribe the encounter: $error');
    } finally {
      if (mounted && _processing) setState(() => _processing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scribeState = _scribe.state.value;
    final recording =
        scribeState.status == AmbientScribeStatus.recording ||
        scribeState.status == AmbientScribeStatus.paused;
    final transcribing =
        _processing || scribeState.status == AmbientScribeStatus.transcribing;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (scribeState.error != null) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(scribeState.error!),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (recording || transcribing)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              transcribing
                  ? 'Translating & Structuring...'
                  : scribeState.status == AmbientScribeStatus.paused
                  ? 'Recording paused during interruption'
                  : 'Listening — tap to stop',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                backgroundColor: theme.colorScheme.surface.withValues(
                  alpha: 0.9,
                ),
              ),
            ),
          ),
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!recording && !transcribing)
                PopupMenuButton<String>(
                  tooltip: 'Choose on-device recognition language',
                  initialValue: _localeId,
                  onSelected: (locale) => setState(() => _localeId = locale),
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: AmbientScribeService.defaultLocaleId,
                      child: Text('Indian English'),
                    ),
                    PopupMenuItem(
                      value: AmbientScribeService.hindiLocaleId,
                      child: Text('Hindi'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _localeId == AmbientScribeService.hindiLocaleId
                          ? 'हिन्दी'
                          : 'EN-IN',
                    ),
                  ),
                ),
              Transform.scale(
                scale: recording ? 1 + (_pulse.value * 0.07) : 1,
                child: child,
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            heroTag: 'ambient-scribe-${widget.patient?.id ?? 'dashboard'}',
            tooltip:
                'Speech recognition runs on-device. The transcript is '
                'sent to ClinCom for chart structuring.',
            onPressed: transcribing ? null : _toggleScribe,
            backgroundColor: recording ? theme.colorScheme.error : null,
            foregroundColor: recording ? theme.colorScheme.onError : null,
            icon: transcribing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(recording ? Icons.stop : Icons.mic),
            label: Text(
              transcribing
                  ? 'Structuring'
                  : recording
                  ? 'Stop Scribe'
                  : 'Scribe Mode',
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum AmbientScribeStatus { idle, recording, paused, transcribing }

@immutable
class AmbientScribeState {
  const AmbientScribeState({
    this.status = AmbientScribeStatus.idle,
    this.error,
  });

  final AmbientScribeStatus status;
  final String? error;
}

abstract interface class NativeSpeechRecognizer {
  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String error, bool permanent) onError,
  });

  Future<List<String>> locales();

  Future<void> listen({
    required String localeId,
    required Duration listenFor,
    required Duration pauseFor,
    required void Function(String words, bool isFinal) onResult,
  });

  Future<void> stop();
}

class _SpeechToTextRecognizer implements NativeSpeechRecognizer {
  final SpeechToText _speech = SpeechToText();

  @override
  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String error, bool permanent) onError,
  }) => _speech.initialize(
    onStatus: onStatus,
    onError: (SpeechRecognitionError error) =>
        onError(error.errorMsg, error.permanent),
  );

  @override
  Future<List<String>> locales() async =>
      (await _speech.locales()).map((locale) => locale.localeId).toList();

  @override
  Future<void> listen({
    required String localeId,
    required Duration listenFor,
    required Duration pauseFor,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
        onDevice: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        contextualPhrases: const [
          'dyspnea',
          'hypertension',
          'diabetes mellitus',
          'myocardial infarction',
          'amlodipine',
          'paracetamol',
          'blood pressure',
          'saans phool rahi hai',
        ],
      ),
    );
  }

  @override
  Future<void> stop() => _speech.stop();
}

class AmbientScribeService with WidgetsBindingObserver {
  AmbientScribeService({NativeSpeechRecognizer? recognizer})
    : _recognizer = recognizer ?? _SpeechToTextRecognizer() {
    WidgetsBinding.instance.addObserver(this);
  }

  static const defaultLocaleId = 'en_IN';
  static const hindiLocaleId = 'hi_IN';
  static const _listenWindow = Duration(minutes: 5);
  static const _pauseWindow = Duration(seconds: 20);
  static const _restartDelay = Duration(milliseconds: 300);

  final NativeSpeechRecognizer _recognizer;
  final ValueNotifier<AmbientScribeState> state = ValueNotifier(
    const AmbientScribeState(),
  );
  final List<String> _completedSegments = [];
  String _currentSegment = '';
  String _localeId = defaultLocaleId;

  /// Locale actually used for the active session (may differ from [_localeId]
  /// after an automatic fallback when the requested locale is unavailable).
  String _activeLocaleId = defaultLocaleId;

  /// Whether the active session is running on a fallback locale.
  bool _usingFallbackLocale = false;
  Timer? _restartTimer;
  bool _initialized = false;
  bool _manualStop = false;
  bool _interrupted = false;
  bool _disposed = false;
  Completer<void>? _finalResultReceived;
  Future<void>? _interruptionStop;

  /// Silent-retry budget for "no speech recognized" before surfacing failure.
  /// Reset on every [startListening] and on every successful result.
  int _noSpeechRetries = 0;
  static const int _maxNoSpeechRetries = 1;

  /// Fallback chain when the requested on-device locale is unavailable.
  /// Order matters: prefer the clinician's preferred Hindi pack (`hi_IN`),
  /// then the English-India pack (`en_IN`), then the US/device default
  /// (`en_US`).
  static const List<String> _fallbackLocaleChain = ['hi_IN', 'en_IN', 'en_US'];

  String get localeId => _localeId;

  /// Locale actually in use for the running session (differs from [localeId]
  /// when an automatic fallback was applied).
  String get activeLocaleId => _activeLocaleId;

  /// Whether the running session fell back to a different on-device locale.
  bool get usingFallbackLocale => _usingFallbackLocale;

  Future<void> startListening({String localeId = defaultLocaleId}) async {
    if (state.value.status != AmbientScribeStatus.idle) {
      throw StateError('The ambient scribe is already active.');
    }
    _localeId = localeId;
    _noSpeechRetries = 0;
    _usingFallbackLocale = false;
    _activeLocaleId = localeId;
    state.value = const AmbientScribeState(
      status: AmbientScribeStatus.transcribing,
    );
    try {
      if (!_initialized) {
        _initialized = await _recognizer.initialize(
          onStatus: _onStatus,
          onError: _onError,
        );
      }
      if (!_initialized) {
        throw StateError(
          'Native speech recognition is unavailable or microphone permission '
          'was denied.',
        );
      }
      _activeLocaleId = await _resolveLocaleWithFallback(
        requested: _localeId,
      );

      _completedSegments.clear();
      _currentSegment = '';
      _manualStop = false;
      state.value = const AmbientScribeState(
        status: AmbientScribeStatus.recording,
      );
      await _startListenWindow();
      if (_interrupted) await _pauseForInterruption();
    } catch (error) {
      _manualStop = true;
      _restartTimer?.cancel();
      state.value = AmbientScribeState(error: error.toString());
      rethrow;
    }
  }

  Future<String> stopAndGetTranscript() async {
    if (state.value.status != AmbientScribeStatus.recording &&
        state.value.status != AmbientScribeStatus.paused) {
      throw StateError('There is no active speech session to stop.');
    }
    _manualStop = true;
    _restartTimer?.cancel();
    _finalResultReceived = Completer<void>();
    state.value = const AmbientScribeState(
      status: AmbientScribeStatus.transcribing,
    );
    try {
      await _recognizer.stop();
      await _finalResultReceived!.future.timeout(
        const Duration(milliseconds: 500),
        onTimeout: () {},
      );
      final transcript = [
        ..._completedSegments,
        if (_currentSegment.trim().isNotEmpty) _currentSegment.trim(),
      ].join(' ').trim();
      if (transcript.isEmpty) {
        // Sprint 28 — silent retry: a single empty ("no speech recognized")
        // stop is retried once on the same locale before failing, absorbing
        // the platform `Bad state: No speech was recognized` crash.
        if (_noSpeechRetries < _maxNoSpeechRetries && !_disposed) {
          _noSpeechRetries++;
          _completedSegments.clear();
          _currentSegment = '';
          _finalResultReceived = null;
          _manualStop = false;
          state.value = const AmbientScribeState(
            status: AmbientScribeStatus.recording,
          );
          await _startListenWindow();
          await Future<void>.delayed(const Duration(milliseconds: 500));
          _manualStop = true;
          _finalResultReceived = Completer<void>();
          state.value = const AmbientScribeState(
            status: AmbientScribeStatus.transcribing,
          );
          try {
            await _recognizer.stop();
            await _finalResultReceived!.future.timeout(
              const Duration(milliseconds: 500),
              onTimeout: () {},
            );
          } catch (_) {
            // A second platform failure is treated as empty below.
          }
          final retryTranscript = [
            ..._completedSegments,
            if (_currentSegment.trim().isNotEmpty) _currentSegment.trim(),
          ].join(' ').trim();
          if (retryTranscript.isNotEmpty) return retryTranscript;
        }
        throw StateError(
          'No speech was recognized. Check the selected language and try again.',
        );
      }
      return transcript;
    } finally {
      _completedSegments.clear();
      _currentSegment = '';
      _interrupted = false;
      _finalResultReceived = null;
      if (!_disposed) state.value = const AmbientScribeState();
    }
  }

  Future<void> _startListenWindow() async {
    if (_manualStop || _interrupted || _disposed) return;
    try {
      await _recognizer.listen(
        localeId: _activeLocaleId,
        listenFor: _listenWindow,
        pauseFor: _pauseWindow,
        onResult: _onResult,
      );
    } catch (error) {
      // Sprint 28 — `error_language_unavailable` (e.g. hi_IN pack missing)
      // falls back to en_US/device default instead of crashing.
      if (_isLanguageUnavailable(error) && !_usingFallbackLocale) {
        final fallback = await _resolveLocaleWithFallback(
          requested: _activeLocaleId,
          forceFallback: true,
        );
        if (fallback != _activeLocaleId) {
          _activeLocaleId = fallback;
          _usingFallbackLocale = true;
          state.value = AmbientScribeState(
            status: AmbientScribeStatus.recording,
            error:
                'Requested speech language unavailable; continuing in $_activeLocaleId.',
          );
          await _recognizer.listen(
            localeId: _activeLocaleId,
            listenFor: _listenWindow,
            pauseFor: _pauseWindow,
            onResult: _onResult,
          );
          return;
        }
      }
      rethrow;
    }
  }

  /// Resolves [requested] to an installed on-device locale, falling back to
  /// `en_US` (then the device default) when the pack is missing. Only throws
  /// when nothing usable is installed at all.
  Future<String> _resolveLocaleWithFallback({
    required String requested,
    bool forceFallback = false,
  }) async {
    final availableLocales = await _recognizer.locales();
    String normalizeLocale(String locale) =>
        locale.replaceAll('-', '_').toLowerCase();
    String? matchFor(String target) {
      for (final locale in availableLocales) {
        if (normalizeLocale(locale) == normalizeLocale(target)) return locale;
      }
      return null;
    }

    if (!forceFallback) {
      final exact = availableLocales.isEmpty ? requested : matchFor(requested);
      if (exact != null) {
        _usingFallbackLocale = false;
        return exact;
      }
    }
    // Requested pack missing (or listen threw language-unavailable): walk the
    // fallback chain, then the device default (first available locale).
    for (final candidate in _fallbackLocaleChain) {
      final match = matchFor(candidate);
      if (match != null) {
        _usingFallbackLocale = true;
        return match;
      }
    }
    if (availableLocales.isNotEmpty) {
      _usingFallbackLocale = true;
      return availableLocales.first;
    }
    if (!forceFallback) {
      // No locale inventory (e.g. headless test fake with empty list):
      // assume the platform default handles the request.
      _usingFallbackLocale = false;
      return requested;
    }
    throw StateError(
      'The selected on-device speech locale $requested is unavailable and no '
      'fallback speech language is installed. Install an offline speech '
      'language pack or choose another locale.',
    );
  }

  static bool _isLanguageUnavailable(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('language_unavailable') ||
        text.contains('language unavailable') ||
        text.contains('locale_unavailable') ||
        text.contains('locale unavailable');
  }

  void _onResult(String words, bool isFinal) {
    if ((_manualStop && !isFinal) || words.trim().isEmpty) return;
    // Any real hypothesis resets the silent no-speech retry budget.
    _noSpeechRetries = 0;
    _currentSegment = words.trim();
    if (isFinal) {
      _completedSegments.add(_currentSegment);
      _currentSegment = '';
      final completion = _finalResultReceived;
      if (completion != null && !completion.isCompleted) {
        completion.complete();
      }
    }
  }

  void _onStatus(String status) {
    if (_manualStop || _disposed) return;
    if (status == SpeechToText.listeningStatus) {
      state.value = const AmbientScribeState(
        status: AmbientScribeStatus.recording,
      );
    } else if (status == SpeechToText.notListeningStatus ||
        status == SpeechToText.doneStatus) {
      state.value = const AmbientScribeState(
        status: AmbientScribeStatus.paused,
      );
      _scheduleRestart();
    }
  }

  void _onError(String message, bool permanent) {
    if (_manualStop || _disposed) return;
    // Sprint 28 — the platform `error_language_unavailable` for a missing
    // pack (e.g. hi_IN) is recovered by switching to the fallback locale
    // instead of dying in a permanent error state.
    if (_isLanguageUnavailable(message)) {
      unawaited(_fallbackAfterLanguageError(message));
      return;
    }
    state.value = AmbientScribeState(
      status: _interrupted
          ? AmbientScribeStatus.paused
          : AmbientScribeStatus.recording,
      error: 'On-device speech recognition: $message',
    );
    if (!permanent) {
      _scheduleRestart();
    } else {
      _manualStop = true;
    }
  }

  /// Recovers from an async `error_language_unavailable` callback by moving the
  /// live session to the fallback locale without stopping the scribe.
  Future<void> _fallbackAfterLanguageError(String message) async {
    if (_manualStop || _disposed || _usingFallbackLocale) {
      state.value = AmbientScribeState(
        status: _interrupted
            ? AmbientScribeStatus.paused
            : AmbientScribeStatus.recording,
        error: 'On-device speech recognition: $message',
      );
      return;
    }
    try {
      final fallback = await _resolveLocaleWithFallback(
        requested: _activeLocaleId,
        forceFallback: true,
      );
      if (_manualStop || _disposed) return;
      _activeLocaleId = fallback;
      _usingFallbackLocale = true;
      state.value = AmbientScribeState(
        status: AmbientScribeStatus.recording,
        error:
            'Requested speech language unavailable; continuing in $_activeLocaleId.',
      );
      await _recognizer.listen(
        localeId: _activeLocaleId,
        listenFor: _listenWindow,
        pauseFor: _pauseWindow,
        onResult: _onResult,
      );
    } catch (error) {
      if (!_manualStop && !_disposed) {
        state.value = AmbientScribeState(
          status: AmbientScribeStatus.paused,
          error: 'Could not resume on-device speech recognition: $error',
        );
      }
    }
  }

  void _scheduleRestart() {
    if (_manualStop || _interrupted || _disposed) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(_restartDelay, () async {
      try {
        await _startListenWindow();
        if (!_interrupted && !_manualStop) {
          state.value = const AmbientScribeState(
            status: AmbientScribeStatus.recording,
          );
        }
      } catch (error) {
        if (!_manualStop && !_disposed) {
          state.value = AmbientScribeState(
            status: AmbientScribeStatus.paused,
            error: 'Could not resume on-device speech recognition: $error',
          );
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _interrupted = true;
      _restartTimer?.cancel();
      unawaited(_pauseForInterruption());
    } else if (state == AppLifecycleState.resumed) {
      _interrupted = false;
      unawaited(_resumeAfterInterruption());
    }
  }

  Future<void> _pauseForInterruption() async {
    if (state.value.status != AmbientScribeStatus.recording) return;
    try {
      state.value = const AmbientScribeState(
        status: AmbientScribeStatus.paused,
      );
      final stopping = _recognizer.stop();
      _interruptionStop = stopping;
      await stopping;
      if (!_manualStop && !_disposed) {
        if (!_interrupted) await _resumeAfterInterruption();
      }
    } catch (error) {
      if (!_manualStop && !_disposed) {
        state.value = AmbientScribeState(
          status: AmbientScribeStatus.paused,
          error: 'Could not pause listening during an interruption: $error',
        );
      }
    }
  }

  Future<void> _resumeAfterInterruption() async {
    if (_manualStop || _disposed) {
      return;
    }
    try {
      await _interruptionStop;
      if (_interrupted ||
          state.value.status != AmbientScribeStatus.paused ||
          _manualStop) {
        return;
      }
      await _startListenWindow();
      state.value = const AmbientScribeState(
        status: AmbientScribeStatus.recording,
      );
    } catch (error) {
      state.value = AmbientScribeState(
        status: AmbientScribeStatus.paused,
        error: 'Could not resume on-device speech recognition: $error',
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _manualStop = true;
    _restartTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    await _recognizer.stop();
    state.dispose();
  }
}

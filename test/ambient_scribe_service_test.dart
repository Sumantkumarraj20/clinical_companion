import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clinical_companion/core/services/ambient_scribe_service.dart';

class _FakeNativeRecognizer implements NativeSpeechRecognizer {
  bool initialized = true;
  List<String> availableLocales = const ['en_IN', 'hi_IN'];
  int listenCalls = 0;
  int stopCalls = 0;
  String? lastLocale;
  String? wordsOnStop;
  void Function(String words, bool isFinal)? onResult;
  void Function(String status)? onStatus;

  @override
  Future<bool> initialize({
    required void Function(String status) onStatus,
    required void Function(String error, bool permanent) onError,
  }) async {
    this.onStatus = onStatus;
    return initialized;
  }

  @override
  Future<List<String>> locales() async => availableLocales;

  @override
  Future<void> listen({
    required String localeId,
    required Duration listenFor,
    required Duration pauseFor,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    listenCalls++;
    lastLocale = localeId;
    this.onResult = onResult;
    expect(listenFor, const Duration(minutes: 5));
    expect(pauseFor, const Duration(seconds: 20));
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    final finalWords = wordsOnStop;
    if (finalWords != null) onResult?.call(finalWords, true);
    onStatus?.call('notListening');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures on-device bilingual speech and stops into a transcript', () async {
    final recognizer = _FakeNativeRecognizer();
    recognizer.wordsOnStop = 'Patient ko saans phool rahi hai';
    final service = AmbientScribeService(recognizer: recognizer);
    addTearDown(service.dispose);

    await service.startListening(localeId: AmbientScribeService.hindiLocaleId);
    expect(service.state.value.status, AmbientScribeStatus.recording);
    expect(recognizer.lastLocale, 'hi_IN');

    recognizer.onResult?.call('Patient ko saans phool rahi hai', false);
    final transcript = await service.stopAndGetTranscript();

    expect(transcript, 'Patient ko saans phool rahi hai');
    expect(recognizer.stopCalls, 1);
    expect(service.state.value.status, AmbientScribeStatus.idle);
  });

  test('restarts native listener after its platform listen window ends', () async {
    final recognizer = _FakeNativeRecognizer();
    final service = AmbientScribeService(recognizer: recognizer);
    addTearDown(service.dispose);
    await service.startListening();

    recognizer.onResult?.call('BP one twenty over eighty', true);
    recognizer.onStatus?.call('done');
    await Future<void>.delayed(const Duration(milliseconds: 350));

    expect(recognizer.listenCalls, 2);
    expect(service.state.value.status, AmbientScribeStatus.recording);
    expect(await service.stopAndGetTranscript(), 'BP one twenty over eighty');
  });

  test('pauses on interruption and resumes listening when foregrounded', () async {
    final recognizer = _FakeNativeRecognizer();
    final service = AmbientScribeService(recognizer: recognizer);
    addTearDown(service.dispose);
    await service.startListening();

    service.didChangeAppLifecycleState(AppLifecycleState.inactive);
    await Future<void>.delayed(Duration.zero);
    expect(service.state.value.status, AmbientScribeStatus.paused);
    expect(recognizer.stopCalls, 1);

    service.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(recognizer.listenCalls, 2);
    expect(service.state.value.status, AmbientScribeStatus.recording);
  });

  test('reports an unavailable offline locale instead of using cloud STT', () async {
    final recognizer = _FakeNativeRecognizer()
      ..availableLocales = const ['en_US'];
    final service = AmbientScribeService(recognizer: recognizer);
    addTearDown(service.dispose);

    await expectLater(
      service.startListening(),
      throwsA(isA<StateError>()),
    );
    expect(service.state.value.error, contains('en_IN is unavailable'));
    expect(recognizer.listenCalls, 0);
  });

  test('transcript segments are appended once across listener restarts', () async {
    final recognizer = _FakeNativeRecognizer();
    final service = AmbientScribeService(recognizer: recognizer);
    addTearDown(service.dispose);
    await service.startListening();

    recognizer.onResult?.call('Amlodipine five milligrams', true);
    recognizer.onStatus?.call('done');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    recognizer.onResult?.call('BP one twenty over eighty', false);

    expect(
      await service.stopAndGetTranscript(),
      'Amlodipine five milligrams BP one twenty over eighty',
    );
  });
}

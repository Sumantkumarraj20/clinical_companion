import 'dart:io';

import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/models/ai_extraction_result.dart';
import 'package:clinical_companion/core/models/document_task.dart';
import 'package:clinical_companion/core/providers/app_providers.dart';
import 'package:clinical_companion/core/services/extraction_pipeline_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic stand-in for the ML Kit + Gemini pipeline so the queue's
/// state machine can be exercised without a platform channel or an API key.
class _FakePipeline extends ExtractionPipelineService {
  _FakePipeline({
    this.rawOcr = 'Patient Name: Asha Rao  Age: 45  Sex: Female',
    this.localResult,
    this.aiResult,
    this.failOcr = false,
    this.failAi = false,
  }) : super(DocumentAiService());

  String rawOcr;
  AiExtractionResult? localResult;
  AiExtractionResult? aiResult;
  bool failOcr;
  bool failAi;

  int refineCalls = 0;

  @override
  Future<String> recognizeRawText(File image) async {
    if (failOcr) {
      throw Exception('ML Kit text recognizer is unavailable');
    }
    return rawOcr;
  }

  @override
  AiExtractionResult? parseLocalText(String rawText) => localResult;

  @override
  Future<PipelineExtraction> refineWithAi(File image, String rawText) async {
    refineCalls++;
    if (failAi) {
      throw const DocumentAiException(
        'Gemini is unreachable right now.',
        type: DocumentAiErrorType.server,
      );
    }
    return PipelineExtraction(
      result: aiResult ?? const AiExtractionResult(),
      source: PipelineSource.ai,
    );
  }

  @override
  void close() {}
}

const _localExtraction = AiExtractionResult(
  patientIdentity: PatientIdentity(name: 'Asha Rao', age: 45, gender: 'Female'),
  encounterContext: EncounterContext(documentType: 'Lab Report'),
  labResults: [AiLabResult(testName: 'Hb', value: '11.2', unit: 'g/dL')],
  clinicalSummary: 'CBC panel',
);

ProviderContainer _container(ExtractionPipelineService pipeline) {
  final container = ProviderContainer(
    overrides: [extractionPipelineProvider.overrideWithValue(pipeline)],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _waitUntil(
  bool Function() condition, {
  String description = 'condition',
}) async {
  for (var i = 0; i < 400; i++) {
    if (condition()) return;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('Timed out waiting for $description');
}

void main() {
  test(
    'a clean local read finishes readyForReview without any AI call',
    () async {
      final pipeline = _FakePipeline(localResult: _localExtraction);
      final container = _container(pipeline);

      container.read(batchExtractionProvider.notifier).addFiles([
        File('/tmp/page-clean.jpg'),
      ]);

      await _waitUntil(
        () =>
            container.read(batchExtractionProvider).length == 1 &&
            container.read(batchExtractionProvider).single.status ==
                ExtractionStatus.readyForReview,
        description: 'local extraction to finish',
      );

      final task = container.read(batchExtractionProvider).single;
      expect(task.source, ExtractionSource.local);
      expect(task.rawOcrText, pipeline.rawOcr);
      expect(pipeline.refineCalls, 0);
      expect(task.errorMessage, isNull);
    },
  );

  test(
    'a messy read escalates to the cloud model and records the raw text',
    () async {
      // A realistic messy transcript: OCR dropped the Hb row and garbled digits.
      const messyTranscript =
          'PATIENT NAME  : ASHA RAO   AGE/SEX : 45/F\n'
          'HB    : 1 1 . 2 g/dL   TLC : 9,800\n'
          'PLATELETS: 1.8Lac   CP  Total\n';

      final pipeline = _FakePipeline(
        rawOcr: messyTranscript,
        aiResult: _localExtraction,
      );
      final container = _container(pipeline);

      container.read(batchExtractionProvider.notifier).addFiles([
        File('/tmp/page-messy.jpg'),
      ]);

      await _waitUntil(
        () =>
            container.read(batchExtractionProvider).single.status ==
            ExtractionStatus.readyForReview,
        description: 'AI fallback extraction to finish',
      );

      final task = container.read(batchExtractionProvider).single;
      expect(pipeline.refineCalls, 1);
      expect(task.source, ExtractionSource.ai);
      expect(
        task.rawOcrText,
        messyTranscript,
        reason: 'the transcript must survive so the clinician can verify it',
      );
      expect(task.extractedData?.patientIdentity.name, 'Asha Rao');
    },
  );

  test('an OCR failure surfaces a message and retryTask recovers it', () async {
    final pipeline = _FakePipeline(
      failOcr: true,
      localResult: _localExtraction,
    );
    final container = _container(pipeline);
    final notifier = container.read(batchExtractionProvider.notifier);

    notifier.addFiles([File('/tmp/page-bad-ocr.jpg')]);
    await _waitUntil(
      () =>
          container.read(batchExtractionProvider).single.status ==
          ExtractionStatus.error,
      description: 'OCR failure to be recorded',
    );

    final failed = container.read(batchExtractionProvider).single;
    expect(failed.errorMessage, contains('Local OCR'));

    pipeline.failOcr = false;
    await notifier.retryTask(failed.id);

    final retried = container.read(batchExtractionProvider).single;
    expect(retried.status, ExtractionStatus.readyForReview);
    expect(retried.errorMessage, isNull);
  });

  test('a cloud failure reports the AI error and can be retried', () async {
    final pipeline = _FakePipeline(failAi: true);
    final container = _container(pipeline);
    final notifier = container.read(batchExtractionProvider.notifier);

    notifier.addFiles([File('/tmp/page-ai-down.jpg')]);
    await _waitUntil(
      () =>
          container.read(batchExtractionProvider).single.status ==
          ExtractionStatus.error,
      description: 'AI failure to be recorded',
    );

    expect(
      container.read(batchExtractionProvider).single.errorMessage,
      contains('Gemini is unreachable'),
    );

    pipeline.failAi = false;
    pipeline.aiResult = _localExtraction;
    await notifier.retryTask(container.read(batchExtractionProvider).single.id);

    expect(
      container.read(batchExtractionProvider).single.status,
      ExtractionStatus.readyForReview,
    );
  });

  test('adding the same file twice does not create a duplicate task', () async {
    final pipeline = _FakePipeline(localResult: _localExtraction);
    final container = _container(pipeline);
    final notifier = container.read(batchExtractionProvider.notifier);

    notifier.addFiles([File('/tmp/page-same.jpg')]);
    notifier.addFiles([File('/tmp/page-same.jpg')]);
    notifier.addFiles([File('/tmp/page-same.jpg')]);

    await _waitUntil(
      () => container.read(batchExtractionProvider).length == 1,
      description: 'duplicate files to collapse',
    );
    expect(container.read(batchExtractionProvider), hasLength(1));
  });

  test('a batch of pages is drained one at a time to completion', () async {
    final pipeline = _FakePipeline(localResult: _localExtraction);
    final container = _container(pipeline);

    container.read(batchExtractionProvider.notifier).addFiles([
      File('/tmp/batch-1.jpg'),
      File('/tmp/batch-2.jpg'),
      File('/tmp/batch-3.jpg'),
    ]);

    await _waitUntil(
      () =>
          container.read(batchExtractionProvider).length == 3 &&
          container
              .read(batchExtractionProvider)
              .every((task) => task.status == ExtractionStatus.readyForReview),
      description: 'the whole batch to become ready',
    );

    final ids = container
        .read(batchExtractionProvider)
        .map((task) => task.id)
        .toSet();
    expect(ids, hasLength(3), reason: 'task ids must be unique');
  });

  test('removeTask drops only the requested page', () async {
    final pipeline = _FakePipeline(localResult: _localExtraction);
    final container = _container(pipeline);
    final notifier = container.read(batchExtractionProvider.notifier);

    notifier.addFiles([File('/tmp/keep.jpg'), File('/tmp/drop.jpg')]);
    await _waitUntil(
      () => container.read(batchExtractionProvider).length == 2,
      description: 'both pages to be queued',
    );

    final dropped = container.read(batchExtractionProvider).last.id;
    notifier.removeTask(dropped);

    final remaining = container.read(batchExtractionProvider);
    expect(remaining, hasLength(1));
    expect(remaining.single.id, isNot(dropped));
  });
}

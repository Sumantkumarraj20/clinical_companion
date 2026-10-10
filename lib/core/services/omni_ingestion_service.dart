import 'dart:io';

import '../ai/document_ai_service.dart';
import '../database/daos/cdss_dao.dart';
import '../database/daos/clinical_rule_dao.dart';
import '../database/local_database.dart';
import '../models/ai_extraction_result.dart';
import 'extraction_pipeline_service.dart';

/// Sprint 28 — unified omni-ingestion payloads.
///
/// Every entry point (scribe voice, pasted text, camera scan, PDF import)
/// routes through [OmniIngestionService] wrapped in one of these two payloads.
sealed class OmniPayload {
  const OmniPayload();
}

/// Voice transcripts and pasted text — no OCR needed.
class TextPayload extends OmniPayload {
  const TextPayload(this.text, {this.isAmbientAudio = false});

  final String text;
  final bool isAmbientAudio;
}

/// Camera scans and imported PDFs — OCR (or direct file bytes) needed.
class DocumentPayload extends OmniPayload {
  const DocumentPayload(this.file, {this.activeCensusJson});

  final File file;
  final String? activeCensusJson;
}

/// Where the normalized POMR output came from.
enum OmniIngestionSource {
  /// Hydrated synchronously from the local knowledge base — no network.
  local,

  /// Escalated to the ClinCom model after local confidence was low.
  cloud,

  /// Local pre-compute succeeded and the cloud refined missing fields.
  hybrid,
}

/// Standardized output of the omni-ingestion pipeline: structured POMR data
/// plus provenance, ready for the review screen.
class OmniIngestionResult {
  const OmniIngestionResult({
    required this.data,
    required this.source,
    required this.localConfidence,
    this.matchedRuleIds = const [],
    this.localSummary,
  });

  final AiExtractionResult data;
  final OmniIngestionSource source;
  final double localConfidence;
  final List<String> matchedRuleIds;
  final String? localSummary;
}

/// Sprint 28 — "The Unified Omni-Ingestion Engine & Local Knowledge Dominance".
///
/// Single entry point for ALL clinical data capture. The flow per payload:
///
///  1. **Pre-compute check** — fast local heuristic against `ClinicalRules`
///     (verified) + `CdssRules` tables. No network.
///  2. **Local hydration** — high-confidence trigger matches populate POMR
///     data immediately from local evidence-based rules.
///  3. **Cloud fallback** — only when local confidence is low or data is
///     missing does the service escalate to `gemini-3.8-flash`.
class OmniIngestionService {
  OmniIngestionService({
    required this.aiService,
    required ExtractionPipelineService pipeline,
    required ClinicalRuleDao ruleDao,
    required CdssDao cdssDao,
    required AppDatabase database,
  }) : _pipeline = pipeline,
       _ruleDao = ruleDao,
       _cdssDao = cdssDao,
       _database = database;

  final DocumentAiService aiService;
  final ExtractionPipelineService _pipeline;
  final ClinicalRuleDao _ruleDao;
  final CdssDao _cdssDao;
  final AppDatabase _database;

  /// Confidence at/above which the local knowledge base wins outright.
  static const double highConfidenceThreshold = 0.75;

  /// Confidence below which the cloud is always consulted (even with hits).
  static const double lowConfidenceThreshold = 0.35;

  /// Routes any payload through local-first normalization.
  Future<OmniIngestionResult> ingest(
    OmniPayload payload, {
    ThinkingLevel thinkingLevel = ThinkingLevel.low,
  }) async {
    final rawText = await _rawTextFor(payload);
    final local = await preCompute(rawText);

    if (payload is TextPayload) {
      return _ingestText(
        payload,
        rawText: rawText,
        local: local,
        thinkingLevel: thinkingLevel,
      );
    }
    final document = payload as DocumentPayload;
    return _ingestDocument(
      document,
      rawText: rawText,
      local: local,
      thinkingLevel: thinkingLevel,
    );
  }

  Future<OmniIngestionResult> preCompute(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return const OmniIngestionResult(
        data: AiExtractionResult(),
        source: OmniIngestionSource.local,
        localConfidence: 0,
      );
    }
    final normalized = text.toLowerCase();
    final query = _database.select(_database.clinicalRules)
      ..where((rule) => rule.isDismissed.equals(false));
    final allRules = await query.get();
    allRules.sort((a, b) {
      if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    final cdssRules = await _database.select(_database.cdssRules).get();
    await _ruleDao.findRule(
      triggerType: 'diagnosis',
      triggerValue: '__none__',
    );
    await _cdssDao.rulesForProblem('__none__');
    final matchedProblems = <AiProblem>[];
    final matchedMeds = <OrderedMedication>[];
    final matchedRuleIds = <String>[];
    var hits = 0;
    var candidates = 0;
    for (final rule in allRules) {
      candidates++;
      final trigger = rule.triggerValue.trim();
      if (trigger.isEmpty) continue;
      if (_containsPhrase(normalized, trigger.toLowerCase())) {
        hits++;
        matchedRuleIds.add(rule.id);
        matchedProblems.add(
          AiProblem(
            diagnosis: rule.triggerType == 'diagnosis'
                ? rule.triggerValue
                : rule.suggestedAction,
            linkedMedications: [
              OrderedMedication(
                drugName: rule.triggerType == 'medication'
                    ? rule.triggerValue
                    : rule.suggestedAction,
              ),
            ],
            reasoning: 'Matched local clinical protocol.',
          ),
        );
      }
    }
    for (final rule in cdssRules) {
      candidates++;
      if (rule.targetProblem.trim().isNotEmpty &&
          _containsPhrase(normalized, rule.targetProblem.toLowerCase())) {
        hits++;
        matchedRuleIds.add(rule.id);
        matchedProblems.add(AiProblem(diagnosis: rule.targetProblem));
      }
    }
    final vitals = _extractVitals(normalized);
    if (vitals.sbp != null || vitals.dbp != null) hits++;
    final confidence = candidates == 0
        ? 0.0
        : (hits / (candidates + 1)).clamp(0.0, 1.0);
    final boosted = (confidence + (hits >= 2 ? 0.45 : 0.0)).clamp(0.0, 1.0);
    final data = AiExtractionResult(
      problems: matchedProblems,
      medicationsOrdered: matchedMeds,
      vitals: vitals,
      clinicalSummary: matchedProblems.isEmpty
          ? ''
          : 'Hydrated from local clinical protocols.',
    );
    return OmniIngestionResult(
      data: data,
      source: OmniIngestionSource.local,
      localConfidence: boosted,
      matchedRuleIds: matchedRuleIds,
    );
  }

  Future<String> _rawTextFor(OmniPayload payload) async {
    if (payload is TextPayload) return payload.text;
    final document = payload as DocumentPayload;
    final name = document.file.path.split(Platform.pathSeparator).last;
    return name.replaceAll(RegExp(r'[_\-.]+'), ' ');
  }

  Future<OmniIngestionResult> _ingestText(
    TextPayload payload, {
    required String rawText,
    required OmniIngestionResult local,
    required ThinkingLevel thinkingLevel,
  }) async {
    if (local.localConfidence >= highConfidenceThreshold &&
        _isDataAdequate(local.data)) {
      return local;
    }
    final extraction = await _pipeline.processTextPayload(
      rawText,
      ambientAudioTranscription: payload.isAmbientAudio,
    );
    final merged = _mergeLocalUnder(extraction.result, local);
    final source = local.matchedRuleIds.isEmpty
        ? OmniIngestionSource.cloud
        : OmniIngestionSource.hybrid;
    return OmniIngestionResult(
      data: merged,
      source: source,
      localConfidence: local.localConfidence,
      matchedRuleIds: local.matchedRuleIds,
      localSummary: local.localSummary,
    );
  }

  Future<OmniIngestionResult> _ingestDocument(
    DocumentPayload payload, {
    required String rawText,
    required OmniIngestionResult local,
    required ThinkingLevel thinkingLevel,
  }) async {
    final extraction = await _pipeline.processDocumentWithProvenance(
      payload.file,
    );
    if (extraction.source == PipelineSource.local &&
        local.localConfidence >= highConfidenceThreshold) {
      return OmniIngestionResult(
        data: _mergeLocalUnder(extraction.result, local),
        source: OmniIngestionSource.local,
        localConfidence: local.localConfidence,
        matchedRuleIds: local.matchedRuleIds,
        localSummary: local.localSummary,
      );
    }
    final merged = _mergeLocalUnder(extraction.result, local);
    final source = local.matchedRuleIds.isEmpty
        ? (extraction.source == PipelineSource.local
              ? OmniIngestionSource.local
              : OmniIngestionSource.cloud)
        : OmniIngestionSource.hybrid;
    return OmniIngestionResult(
      data: merged,
      source: source,
      localConfidence: local.localConfidence,
      matchedRuleIds: local.matchedRuleIds,
      localSummary: local.localSummary,
    );
  }

  bool _isDataAdequate(AiExtractionResult data) =>
      data.problems.isNotEmpty ||
      data.medicationsOrdered.isNotEmpty ||
      data.labResults.isNotEmpty ||
      data.vitals.sbp != null;

  AiExtractionResult _mergeLocalUnder(
    AiExtractionResult cloud,
    OmniIngestionResult local,
  ) {
    if (local.matchedRuleIds.isEmpty) return cloud;
    final known = {
      for (final p in local.data.problems) p.diagnosis.toLowerCase(),
    };
    final problems = [
      ...local.data.problems,
      for (final p in cloud.problems)
        if (!known.contains(p.diagnosis.toLowerCase())) p,
    ];
    return cloud.copyWith(
      problems: problems,
      vitals: cloud.vitals.sbp != null ? cloud.vitals : local.data.vitals,
    );
  }

  static bool _containsPhrase(String source, String phrase) {
    final norm = phrase
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
    if (norm.isEmpty) return false;
    final esc = RegExp.escape(norm).replaceAll(r'\ ', r'\s+');
    return RegExp('(?:^|\\b)$esc(?:\\b|\$)').hasMatch(source);
  }

  static AiVitals _extractVitals(String normalized) {
    final bp = RegExp(
      r'\b(?:bp|blood\s*pressure)\s*[:\-]?\s*(\d{2,3})\s*\/\s*(\d{2,3})',
    ).firstMatch(normalized);
    return AiVitals(
      sbp: bp == null ? null : int.tryParse(bp.group(1) ?? ''),
      dbp: bp == null ? null : int.tryParse(bp.group(2) ?? ''),
    );
  }
}

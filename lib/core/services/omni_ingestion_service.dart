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
  const TextPayload(
    this.text, {
    this.isAmbientAudio = false,
    this.activeCensusJson,
  });

  final String text;
  final bool isAmbientAudio;
  final String? activeCensusJson;
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
    this.rawText,
  });

  final AiExtractionResult data;
  final OmniIngestionSource source;
  final double localConfidence;
  final List<String> matchedRuleIds;
  final String? localSummary;
  final String? rawText;
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
    required this.database,
  }) : _pipeline = pipeline,
       _ruleDao = ruleDao,
       _cdssDao = cdssDao;

  final DocumentAiService aiService;
  final ExtractionPipelineService _pipeline;
  final ClinicalRuleDao _ruleDao;
  final CdssDao _cdssDao;
  final AppDatabase database;

  /// Confidence at/above which the local knowledge base wins outright.
  static const double highConfidenceThreshold = 0.75;

  /// Routes any payload through local-first normalization.
  Future<OmniIngestionResult> ingest(OmniPayload payload) async {
    final rawText = await _rawTextFor(payload);
    final local = await preCompute(rawText);

    if (payload is TextPayload) {
      return _ingestText(payload, rawText: rawText, local: local);
    }
    final document = payload as DocumentPayload;
    return _ingestDocument(document, rawText: rawText, local: local);
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
    final allRules = await _ruleDao.activeProtocols();
    final verifiedRules = allRules.where((rule) => rule.isVerified).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final cdssRules = await _cdssDao.allRules();
    final matchedProblems = <AiProblem>[];
    final matchedMeds = <OrderedMedication>[];
    final matchedRuleIds = <String>[];
    var hits = 0;
    for (final rule in verifiedRules) {
      final trigger = rule.triggerValue.trim();
      if (trigger.isEmpty) continue;
      if (_containsPhrase(normalized, trigger.toLowerCase())) {
        hits++;
        matchedRuleIds.add(rule.id);
        final diagnosis = rule.triggerType == 'diagnosis'
            ? rule.triggerValue
            : rule.triggerType == 'symptom'
            ? rule.triggerValue
            : '';
        final reasoning = [
          rule.evidenceRationale.trim(),
          rule.suggestedAction.trim(),
          ...rule.recommendedManagement,
        ].where((item) => item.isNotEmpty).join(' ');
        if (diagnosis.isNotEmpty) {
          matchedProblems.add(
            AiProblem(
              diagnosis: diagnosis,
              reasoning: reasoning,
              linkedInvestigations: rule.recommendedInvestigations
                  .map((test) => AiInvestigation(testName: test))
                  .toList(growable: false),
            ),
          );
        }
        if (rule.triggerType == 'medication') {
          matchedMeds.add(OrderedMedication(drugName: rule.triggerValue));
        }
      }
    }
    for (final rule in cdssRules) {
      if (rule.targetProblem.trim().isNotEmpty &&
          _containsPhrase(normalized, rule.targetProblem.toLowerCase())) {
        hits++;
        matchedRuleIds.add(rule.id);
        matchedProblems.add(AiProblem(diagnosis: rule.targetProblem));
      }
    }
    final vitals = _extractVitals(normalized);
    if (vitals.sbp != null || vitals.dbp != null) hits++;
    final confidence = hits == 0
        ? 0.0
        : (0.75 + (hits > 1 ? 0.15 : 0.0)).clamp(0.0, 1.0);
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
      localConfidence: confidence,
      matchedRuleIds: matchedRuleIds,
      rawText: rawText,
    );
  }

  Future<String> _rawTextFor(OmniPayload payload) async {
    if (payload is TextPayload) return payload.text;
    final document = payload as DocumentPayload;
    return _pipeline.recognizeRawText(document.file);
  }

  Future<OmniIngestionResult> _ingestText(
    TextPayload payload, {
    required String rawText,
    required OmniIngestionResult local,
  }) async {
    if (local.localConfidence >= highConfidenceThreshold &&
        _isDataAdequate(local.data)) {
      return local;
    }
    final extraction = await _pipeline.processTextPayload(
      rawText,
      activeCensusJson: payload.activeCensusJson,
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
      rawText: rawText,
    );
  }

  Future<OmniIngestionResult> _ingestDocument(
    DocumentPayload payload, {
    required String rawText,
    required OmniIngestionResult local,
  }) async {
    if (local.localConfidence >= highConfidenceThreshold &&
        _isDataAdequate(local.data)) {
      return local;
    }
    final extraction = await _pipeline.processRecognizedDocumentWithProvenance(
      payload.file,
      rawText,
      activeCensusJson: payload.activeCensusJson,
    );
    if (extraction.source == PipelineSource.local &&
        local.localConfidence >= highConfidenceThreshold) {
      return OmniIngestionResult(
        data: _mergeLocalUnder(extraction.result, local),
        source: OmniIngestionSource.local,
        localConfidence: local.localConfidence,
        matchedRuleIds: local.matchedRuleIds,
        localSummary: local.localSummary,
        rawText: rawText,
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
      rawText: rawText,
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
      medicationsOrdered: [
        ...local.data.medicationsOrdered,
        for (final medication in cloud.medicationsOrdered)
          if (!local.data.medicationsOrdered.any(
            (localMedication) =>
                localMedication.drugName.toLowerCase() ==
                medication.drugName.toLowerCase(),
          ))
            medication,
      ],
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

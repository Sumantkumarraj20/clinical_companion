import 'dart:convert';
import 'clincom_escalation.dart';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../ai/document_ai_service.dart';
import '../models/ai_extraction_result.dart';
import '../models/document_task.dart';
import '../utils/clinical_date_parser.dart';

/// Provenance of an extraction, surfaced to the UI so reviewers can tell
/// "Locally Extracted (Free)" apart from "ClinCom Extracted".
enum PipelineSource { local, ai }

/// Resolves the timestamp a scanned document should be filed under.
///
/// Priority order matters clinically — using the ingestion date instead of the
/// performed date silently re-dates old reports as "today", which is the
/// failure mode reported from the wards:
///
///  1. the date printed on the document (collection / performed date),
///  2. the file's own last-modified time (a reasonable proxy when a document
///     was exported or messaged shortly after being produced),
///  3. the current time, only as a last resort.
DateTime resolveDocumentedAt(
  String rawOcrText,
  String? filePath, {
  DateTime? now,
}) {
  final fromText = ClinicalDateParser.parseClinicalDate(rawOcrText, now: now);
  if (fromText != null) return fromText;

  if (filePath != null && filePath.isNotEmpty) {
    try {
      final file = File(filePath);
      if (file.existsSync()) return file.lastModifiedSync();
    } catch (_) {
      // Unreadable path (e.g. content:// on Android) — fall through.
    }
  }

  return now ?? DateTime.now();
}

class PipelineExtraction {
  const PipelineExtraction({required this.result, required this.source});

  final AiExtractionResult result;
  final PipelineSource source;

  ExtractionSource get taskSource => switch (source) {
    PipelineSource.local => ExtractionSource.local,
    PipelineSource.ai => ExtractionSource.ai,
  };
}

class ExtractionPipelineService {
  ExtractionPipelineService(
    this._aiService, {
    Future<List<String>> Function()? historicalAssociationsLoader,
  }) : _historicalAssociationsLoader = historicalAssociationsLoader;

  final DocumentAiService _aiService;
  final Future<List<String>> Function()? _historicalAssociationsLoader;

  // Created on first use so tests / headless builds can subclass this service
  // without touching the ML Kit platform channel.
  TextRecognizer? _textRecognizerInstance;
  TextRecognizer get _textRecognizer =>
      _textRecognizerInstance ??= TextRecognizer();

  /// Transcripts shorter than this are treated as "OCR did not really work"
  /// and always escalate to the cloud model instead of trusting a regex hit.
  static const int _minReliableOcrLength = 50;

  /// Self-learning synonym table: OCR variants → canonical keys.
  /// Regex in [_attemptLocalParsing] only targets the canonical keys
  /// (Hb, TLC, Platelets, ...), so extend this map to improve hit rates
  /// without touching patterns.
  static const Map<String, String> _labSynonyms = {
    'hemoglobin': 'Hb',
    'haemoglobin': 'Hb',
    'hgb': 'Hb',
    'hb%': 'Hb',
    'wbc': 'TLC',
    'white blood cells': 'TLC',
    'white blood cell': 'TLC',
    'total leucocyte count': 'TLC',
    'total leukocyte count': 'TLC',
    'tlc': 'TLC',
    'platelet count': 'Platelets',
    'platelets count': 'Platelets',
    'platelets': 'Platelets',
    'platelet': 'Platelets',
    'plt': 'Platelets',
    'red blood cells': 'RBC',
    'red blood cell': 'RBC',
    'packed cell volume': 'PCV',
    'haematocrit': 'PCV',
    'hematocrit': 'PCV',
    'hct': 'PCV',
    'erythrocyte sedimentation rate': 'ESR',
    'c-reactive protein': 'CRP',
    'c reactive protein': 'CRP',
    'serum creatinine': 'Creatinine',
    'blood urea': 'Urea',
    'random blood sugar': 'Glucose',
    'fasting blood sugar': 'Glucose',
    'post prandial blood sugar': 'Glucose',
    'rbs': 'Glucose',
    'fbs': 'Glucose',
    'ppbs': 'Glucose',
    'hba1c': 'HbA1c',
    'hb a1c': 'HbA1c',
    'glycated hemoglobin': 'HbA1c',
    'glycated haemoglobin': 'HbA1c',
  };

  /// Lowercase + replace synonym variants with canonical keys.
  /// Called before [_attemptLocalParsing] so patterns stay minimal.
  String _normalizeOcrText(String rawText) {
    return _normalizeOcrTextInBackground(rawText);
  }

  /// Normalization is deliberately isolated from rendering; OCR callbacks can
  /// contain long multi-page transcripts and must not cost a bedside frame.
  Future<String> normalizeOcrTextOffMain(String rawText) {
    // Startup overhead exceeds the work for a single short lab line. Long OCR
    // transcripts are isolated, which is the path that could otherwise jank.
    if (rawText.length < 4096) {
      return Future<String>.value(_normalizeOcrTextInBackground(rawText));
    }
    return Isolate.run(() => _normalizeOcrTextInBackground(rawText));
  }

  static String _normalizeOcrTextInBackground(String rawText) {
    var normalized = rawText.toLowerCase();
    final keys = _labSynonyms.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in keys) {
      final target = _labSynonyms[key]!;
      normalized = normalized.replaceAll(
        RegExp('\\b${RegExp.escape(key)}\\b'),
        target,
      );
    }
    return normalized;
  }

  Future<PipelineExtraction> processDocumentWithProvenance(File image) async {
    final rawText = await recognizeRawText(image);

    final local = parseLocalText(rawText);
    if (local != null) {
      return PipelineExtraction(result: local, source: PipelineSource.local);
    }

    return refineWithAi(image, rawText);
  }

  /// Sends clinician-pasted text directly to ClinCom, without OCR, image
  /// hashing, local lab parsing, or image preparation.
  Future<PipelineExtraction> processTextWithProvenance(
    String rawText, {
    String? activeCensusJson,
  }) async {
    if (rawText.trim().isEmpty) {
      throw ArgumentError.value(rawText, 'rawText', 'Text cannot be empty');
    }
    final historicalAssociations =
        await _historicalAssociationsLoader?.call() ?? const <String>[];
    final result = await _aiService.extractDocument(
      image: null,
      prompt: _polishPrompt(
        rawText,
        activeCensusJson: activeCensusJson,
        includeImage: false,
        historicalAssociations: historicalAssociations,
      ),
    );
    return PipelineExtraction(result: result, source: PipelineSource.ai);
  }

  Future<AiExtractionResult> processDocument(File image) async {
    return (await processDocumentWithProvenance(image)).result;
  }

  Future<String> recognizeRawText(File image) async {
    final recognized = await _textRecognizer.processImage(
      InputImage.fromFile(image),
    );
    return recognized.text;
  }

  /// Free, instant on-device parse of an already recognised transcript.
  ///
  /// Returns `null` when the transcript is too short or too messy to trust,
  /// which is the signal for the caller to escalate to ClinCom.
  AiExtractionResult? parseLocalText(String rawText) {
    if (rawText.trim().length < _minReliableOcrLength) return null;
    final localData = _attemptLocalParsing(_normalizeOcrText(rawText));
    if (localData == null || !_isDataAdequate(localData)) return null;
    return localData;
  }

  /// Escalates to ClinCom to clean up a messy / incomplete local read.
  ///
  /// Sprint 17 "ClinCom" — the image is now sent **only when it earns its
  /// cost**. Dense, trustworthy on-device OCR takes the text-only path; sparse
  /// or handwriting-shaped OCR escalates to a compressed image so the vision
  /// model reads the page itself.
  ///
  /// [activeCensusJson] is the clinician's current inpatient census, so a page
  /// carrying only a bed number ("Bed 12, R/O 2 days...") can be resolved to a
  /// real patient without a second human step.
  Future<PipelineExtraction> refineWithAi(
    File image,
    String rawText, {
    String? activeCensusJson,
  }) async {
    final escalation = chooseEscalation(ocrText: rawText);
    final historicalAssociations =
        await _historicalAssociationsLoader?.call() ?? const <String>[];
    final prompt = _polishPrompt(
      rawText,
      activeCensusJson: activeCensusJson,
      includeImage: escalation == ClinComEscalation.multimodalVision,
      historicalAssociations: historicalAssociations,
    );

    // Text-only skips the image entirely: no base64 upload, no vision tokens.
    final File? payload = escalation == ClinComEscalation.multimodalVision
        ? await _compressForAI(image)
        : null;

    final aiResult = await _aiService.extractDocument(
      image: payload,
      prompt: prompt,
    );
    return PipelineExtraction(result: aiResult, source: PipelineSource.ai);
  }

  /// Prompt used to polish a document the local regex path could not handle.
  String _polishPrompt(
    String rawText, {
    String? activeCensusJson,
    bool includeImage = true,
    List<String> historicalAssociations = const [],
  }) {
    final transcript = rawText.trim();
    final censusJson = (activeCensusJson ?? '').trim();

    // Empty census (no active inpatients, or provider unavailable) simply omits
    // the block — a page with no bed number must not be nudged into inventing
    // a patient match.
    final censusBlock = censusJson.isEmpty
        ? ''
        : '''ACTIVE INPATIENT CENSUS (authoritative, from the clinician's current ward):
$censusJson

If the page identifies a patient ONLY by bed or ward number and carries no name,
resolve it against the census above and report the matching `patient_id`. If no
bed number is present, or the bed is ambiguous, set `patient_id` to null rather
than guessing a patient.''';

    final practicePatterns = historicalAssociations.isEmpty
        ? ''
        : '''CLINICIAN'S HISTORICAL PRACTICE PATTERNS (frequency-ranked, local data):
${jsonEncode(historicalAssociations)}
Treat these associations only as contextual evidence, not as rules. Do not
override the current document or established guidelines; never infer a link
solely because it appears in this list.''';

    return '''
You are ClinCom, an expert Chief Medical Officer and the clinician's second
brain. You read Indian clinical paperwork — typed and handwritten — and return
strict JSON for a downstream EHR.

You are an elite Medical Informatician. You will receive messy, unstructured
clinical text or OCR data. You MUST normalize colloquialisms, abbreviations,
and brand names to uniform, standard medical vocabulary (for example,
"Pipzo" -> "Piperacillin/Tazobactam" and "KFT" -> "Renal Function Test").
Preserve verbatim source conclusions and never alter a dose, measurement, or
clinically meaningful fact.

You are an expert clinical reasoner. You must organize all extracted
medications, labs, and procedures under the specific Diagnosis/Problem they
are intended to manage. If a medication's purpose is unclear, place it in the
'unlinked_data' array. Never guess wildly; rely on established medical
guidelines.

When extracting medications, act as a clinical pharmacist. If a documented
active problem contraindicates a medication or requires a dose adjustment,
include a concise, evidence-grounded item in `clinical_warnings` with
medication, condition, warning, and (when supported) dose_adjustment. Do not
invent contraindications or patient conditions. If the source states or
strongly indicates a medication side effect (for example, "developed rash from
penicillin"), extract that reaction as a distinct problem in `pomr_data`; do
not infer an adverse reaction from a known side-effect list alone.

NON-NEGOTIABLE CLINICAL RULES:
1. STANDARDISE every medical abbreviation to its full clinical term
   (e.g. "H6b" -> "Haemoglobin", "TLC" -> "Total Leucocyte Count",
   "R/O" -> "Review Of", "K/C" -> "Known Case of"). Clinicians scan for
   meaning, not shorthand.
2. NEVER GUESS a value. A field you cannot read is null, not a plausible
   number. A fabricated haemoglobin is a clinical hazard.
3. DOCUMENT DATE: extract the date the document was WRITTEN (the report's own
   date, the sample-collection date, or the top-right date on a prescription)
   into `encounterDetails.date` as ISO-8601 (YYYY-MM-DD). NEVER substitute
   today's date — a back-dated report entered today must keep its true date.
4. CENSUS INFERENCE: if the source carries a bed/ward number but no patient
   name, cross-reference the appended active census JSON and output the matched
   id in `inferred_patient_id`. If the bed is missing or ambiguous, emit null —
   never guess a patient.
5. LABS: expand test names to standard units ("Serum Creatinine"), keep the
   original value, unit and reference range exactly as printed, and set
   `is_abnormal` only when the report itself flags it.
6. Keep `clinical_summary` to ONE sentence.

${includeImage ? 'You are given a clinical document photo together with the raw on-device OCR\ntranscript of the same page.' : 'You are given raw, unstructured clinical text pasted by the clinician or\nrecognized by OCR. No image is attached: rely on this text exclusively.'}
The source text may be noisy: it may miss table cells, swap digits, or drop headers.

$censusBlock

$practicePatterns


Clean and normalise the data, then return structured JSON:
- Repair obvious OCR damage (e.g. "H6b" -> Hb, "1 3.2" -> 13.2) but NEVER
  invent a value that is not evidenced by the image or the transcript.
- Return the universal payload using this shape:
  `"inferredPatientDemographics": {"name": null, "age": null,
  "gender": null, "mrn": null},
  "encounterDetails": {"date": null, "type": "OPD",
  "department": null, "ward_bed": null, "vitals": {"sbp": null,
  "dbp": null, "pulse": null, "spo2": null, "temperature_c": null,
  "respiratory_rate": null, "map": null}},
  "pomr_data": [{"diagnosis": "Hypertension",
  "linked_medications": [{"name": "Amlodipine", "dose": "5mg"}],
  "linked_investigations": [{"test_name": "KFT"}],
  "linked_procedures": [], "reasoning": "..."}],
  "unlinked_data": {"medications": [], "investigations": [],
  "procedures": []}`.
  Each problem may contain multiple management items. Investigation objects
  should include any printed `value`, `unit`, and `is_abnormal`; medication
  objects may include `frequency`. Give concise reasoning grounded in the page
  and established guidelines.
- Put every medication, investigation, and procedure whose intended problem is
  unclear into the matching array in `unlinked_data`. Do not duplicate an
  item in linked and unlinked management. Never invent a diagnosis or link.
- Include `clinical_warnings` as an array (empty when none); each warning has
  `medication`, `condition`, `warning`, and optional `dose_adjustment`.
- Do not emit the legacy flat arrays; all medications, investigations (including
  results), and procedures belong in `pomr_data` or `unlinked_data`.
- Populate demographics and encounter details only when present in the source.
  Use `type` values OPD, IPD, or ER when supported by the source, otherwise
  Clinical Note. Put vitals inside `encounterDetails.vitals`.
- Use null / [] for anything genuinely absent. Do not guess.
- Preserve original units. Flag a lab is_abnormal only when the source does.
- clinical_summary must be a terse clinician-facing description of what this
  document is and what it contains.

CONCLUSION (do not skip this):
- ALWAYS transcribe the report's closing narrative block into "conclusion"
  verbatim. On pathology reports it is usually headed "Conclusion",
  "Histopathological Report" or "Final Report"; on imaging it is "Impression",
  "Findings" or "Report"; on discharge summaries "Final Remarks", "Advice" or
  "Summary of Treatment". It sits at the BOTTOM of the page, after the tables.
- A report's numbers without its conclusion are clinically worthless — the
  conclusion states the diagnosis, the grade, the urgency and the follow-up.
  Never leave "conclusion" empty when such a block is visible.
- Copy the text as written, including hedging ("features suggestive of",
  "cannot be excluded"). Do not soften, summarise away or harden it.
- If the page genuinely has no conclusion block, return "conclusion": "".

Original source text (clinician-pasted text or on-device OCR transcript):
${transcript.isEmpty ? '(No text was provided — rely on the image only.)' : transcript}
''';
  }

  /// Lightweight probe for UI badges: runs OCR + local regex only, never
  /// calls ClinCom. Returns non-null when the free path would succeed.
  Future<PipelineExtraction?> tryLocalOnly(File image) async {
    final rawText = await recognizeRawText(image);
    final local = parseLocalText(rawText);
    if (local == null) return null;
    return PipelineExtraction(result: local, source: PipelineSource.local);
  }

  /// Releases the ML Kit text recognizer. Called by the provider on dispose.
  void close() {
    _textRecognizerInstance?.close();
    _textRecognizerInstance = null;
  }

  AiExtractionResult? _attemptLocalParsing(String text) {
    if (text.trim().isEmpty) return null;

    final labs = <AiLabResult>[];
    String? name;
    int? age;
    String? gender;

    final nameMatch = RegExp(
      r'(?:patient(?:\s+name)?|name)\s*[:\-]\s*([A-Za-z][A-Za-z .]{1,60})',
      caseSensitive: false,
    ).firstMatch(text);
    if (nameMatch != null) {
      var candidate = (nameMatch.group(1) ?? '').trim();
      candidate = candidate
          .split(
            RegExp(r'\b(?:age|sex|gender|dob|id|date)\b', caseSensitive: false),
          )
          .first
          .trim();
      if (candidate.length >= 2) name = candidate;
    }

    final ageMatch = RegExp(
      r'\bage\s*[:\-]?\s*(\d{1,3})\s*(?:y(?:ea)?rs?)?\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (ageMatch != null) age = int.tryParse(ageMatch.group(1) ?? '');

    final sexMatch = RegExp(
      r'\b(?:sex|gender)\s*[:\-]?\s*(male|female|m\/f|\bm\b|\bf\b)',
      caseSensitive: false,
    ).firstMatch(text);
    if (sexMatch != null) {
      final raw = sexMatch.group(1)?.toLowerCase();
      gender = switch (raw) {
        'm' || 'm/f' => 'Male',
        'f' => 'Female',
        _ => sexMatch.group(1),
      };
    }

    const labPatterns = <String, String>{
      // Canonical keys only — input is already synonym-normalized.
      'Hb': r'\bhb\b\s*[:\-]?\s*(\d+(?:\.\d+)?)\s*(g\/?dl)?',
      'TLC': r'\btlc\b\s*[:\-]?\s*(\d+(?:[.,]\d+)?)',
      'Platelets': r'\bplatelets\b\s*[:\-]?\s*(\d+(?:[.,]\d+)?)',
      'RBC': r'\brbc\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'PCV': r'\bpcv\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'MCV': r'\bmcv\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'MCH': r'\bmch\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'ESR': r'\besr\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'CRP': r'\bcrp\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Creatinine': r'\bcreatinine\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Urea': r'\burea\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Glucose': r'\bglucose\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'HbA1c': r'\bhba1c\b\s*[:\-]?\s*(\d+(?:\.\d+)?)\s*(%)?',
      'Cholesterol': r'\bcholesterol\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Triglycerides': r'\btriglycerides\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'SGOT': r'\bsgot\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'SGPT': r'\bsgpt\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Bilirubin': r'\bbilirubin\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Sodium': r'\bsodium\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
      'Potassium': r'\bpotassium\b\s*[:\-]?\s*(\d+(?:\.\d+)?)',
    };

    for (final entry in labPatterns.entries) {
      final match = RegExp(entry.value, caseSensitive: false).firstMatch(text);
      if (match == null) continue;
      final rawValue = (match.group(1) ?? '').replaceAll(',', '');
      if (rawValue.isEmpty || double.tryParse(rawValue) == null) continue;
      var unit = '';
      if (match.groupCount >= 2) unit = (match.group(2) ?? '').trim();
      if (unit.isEmpty) unit = _defaultUnitFor(entry.key);
      labs.add(
        AiLabResult(
          testName: entry.key,
          value: rawValue,
          unit: unit.isEmpty ? null : unit,
        ),
      );
    }

    int? sbp;
    int? dbp;
    int? pr;
    int? spo2;
    double? tempC;

    final bpMatch = RegExp(
      r'\b(?:bp|blood\s*pressure)\s*[:\-]?\s*(\d{2,3})\s*\/\s*(\d{2,3})',
      caseSensitive: false,
    ).firstMatch(text);
    if (bpMatch != null) {
      sbp = int.tryParse(bpMatch.group(1) ?? '');
      dbp = int.tryParse(bpMatch.group(2) ?? '');
    }
    final pulseMatch = RegExp(
      r'\b(?:pulse|heart\s*rate|\bhr\b)\s*[:\-]?\s*(\d{2,3})\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (pulseMatch != null) pr = int.tryParse(pulseMatch.group(1) ?? '');

    final spo2Match = RegExp(
      r'\bspo2\b\s*[:\-]?\s*(\d{2,3})\s*%?',
      caseSensitive: false,
    ).firstMatch(text);
    if (spo2Match != null) spo2 = int.tryParse(spo2Match.group(1) ?? '');

    final tempMatch = RegExp(
      r'\btemp(?:erature)?\s*[:\-]?\s*(\d{2,3}(?:\.\d+)?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (tempMatch != null) {
      final raw = double.tryParse(tempMatch.group(1) ?? '');
      if (raw != null) tempC = raw > 45 ? (raw - 32) * 5 / 9 : raw;
    }

    final hasDemographics = name != null && age != null;
    if (labs.length < 2 && !hasDemographics) return null;

    return AiExtractionResult(
      patientIdentity: PatientIdentity(name: name, age: age, gender: gender),
      encounterContext: const EncounterContext(documentType: 'Lab Report'),
      vitals: AiVitals(
        sbp: sbp,
        dbp: dbp,
        pr: pr,
        temperatureC: tempC,
        spo2: spo2,
      ),
      labResults: labs,
      clinicalSummary: 'Parsed locally on-device (free OCR regex path).',
    );
  }

  String _defaultUnitFor(String testName) {
    return switch (testName) {
      'Hb' => 'g/dL',
      'TLC' => '/cumm',
      'Platelets' => '/cumm',
      'PCV' => '%',
      'HbA1c' => '%',
      'Glucose' || 'Cholesterol' || 'Triglycerides' || 'Urea' => 'mg/dL',
      'Creatinine' => 'mg/dL',
      'Sodium' || 'Potassium' => 'mEq/L',
      _ => '',
    };
  }

  bool _isDataAdequate(AiExtractionResult data) {
    return data.labResults.isNotEmpty || data.medicationsOrdered.isNotEmpty;
  }

  Future<File> _compressForAI(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final targetPath = '${file.absolute.parent.path}/ai_opt_$fileName';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    if (result == null) {
      throw const DocumentAiException(
        'Image preparation did not complete. Please retry this page.',
        type: DocumentAiErrorType.imageInvalid,
      );
    }
    return File(result.path);
  }
}

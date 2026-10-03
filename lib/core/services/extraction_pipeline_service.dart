import 'dart:io';
import 'dart:isolate';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../ai/document_ai_service.dart';
import '../models/ai_extraction_result.dart';
import '../models/document_task.dart';

/// Provenance of an extraction, surfaced to the UI so reviewers can tell
/// "Locally Extracted (Free)" apart from "AI Extracted".
enum PipelineSource { local, ai }

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
  ExtractionPipelineService(this._aiService);

  final DocumentAiService _aiService;

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
  /// which is the signal for the caller to escalate to Gemini.
  AiExtractionResult? parseLocalText(String rawText) {
    if (rawText.trim().length < _minReliableOcrLength) return null;
    final localData = _attemptLocalParsing(_normalizeOcrText(rawText));
    if (localData == null || !_isDataAdequate(localData)) return null;
    return localData;
  }

  /// Escalates to Gemini to clean up a messy / incomplete local read.
  ///
  /// The raw on-device transcript is handed to the model as context so it can
  /// correct OCR noise rather than re-reading the pixels cold. The image is
  /// still sent because handwriting and tables are unreliable in OCR alone.
  Future<PipelineExtraction> refineWithAi(File image, String rawText) async {
    final compressed = await _compressForAI(image);
    final aiResult = await _aiService.extractDocument(
      image: compressed,
      prompt: _polishPrompt(rawText),
    );
    return PipelineExtraction(result: aiResult, source: PipelineSource.ai);
  }

  /// Prompt used to polish a document the local regex path could not handle.
  String _polishPrompt(String rawText) {
    final transcript = rawText.trim();
    return '''
You are given a clinical document photo together with the raw on-device OCR
transcript of the same page. The transcript is noisy: it may miss table cells,
swap digits, or drop headers.

Clean and normalise the data, then return structured JSON:
- Repair obvious OCR damage (e.g. "H6b" -> Hb, "1 3.2" -> 13.2) but NEVER
  invent a value that is not evidenced by the image or the transcript.
- Fill patient_identity, encounter_context, vitals, medications_ordered and
  lab_results from whatever the page actually contains.
- Use null / [] for anything genuinely absent. Do not guess.
- Preserve original units. Flag a lab is_abnormal only when the source does.
- clinical_summary must be a terse clinician-facing description of what this
  document is and what it contains.

Raw on-device OCR transcript:
${transcript.isEmpty ? '(OCR returned no text — rely on the image only.)' : transcript}
''';
  }

  /// Lightweight probe for UI badges: runs OCR + local regex only, never
  /// calls Gemini. Returns non-null when the free path would succeed.
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

import 'dart:io';
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
  final _textRecognizer = TextRecognizer();

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
    final recognizedText = await _textRecognizer.processImage(
      InputImage.fromFile(image),
    );
    final rawText = recognizedText.text;

    final requiresAiFallback = rawText.trim().length < 50;

    if (!requiresAiFallback) {
      final localData = _attemptLocalParsing(_normalizeOcrText(rawText));
      if (localData != null && _isDataAdequate(localData)) {
        return PipelineExtraction(result: localData, source: PipelineSource.local);
      }
    }

    final compressed = await _compressForAI(image);
    final aiResult = await _aiService.extractDocument(
      image: compressed,
      prompt:
          'Extract patient demographics and lab values. OCR context: $rawText',
    );
    return PipelineExtraction(result: aiResult, source: PipelineSource.ai);
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

  /// Lightweight probe for UI badges: runs OCR + local regex only, never
  /// calls Gemini. Returns non-null when the free path would succeed.
  Future<PipelineExtraction?> tryLocalOnly(File image) async {
    final rawText = await recognizeRawText(image);
    if (rawText.trim().length < 50) return null;
    final localData = _attemptLocalParsing(_normalizeOcrText(rawText));
    if (localData == null || !_isDataAdequate(localData)) return null;
    return PipelineExtraction(result: localData, source: PipelineSource.local);
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
            RegExp(
              r'\b(?:age|sex|gender|dob|id|date)\b',
              caseSensitive: false,
            ),
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
      final match =
          RegExp(entry.value, caseSensitive: false).firstMatch(text);
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
      'Glucose' ||
      'Cholesterol' ||
      'Triglycerides' ||
      'Urea' =>
        'mg/dL',
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
    return File(result!.path);
  }
}

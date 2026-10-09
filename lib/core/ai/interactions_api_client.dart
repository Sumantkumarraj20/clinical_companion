import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Sprint 27 — "The Interactions API Migration & Adaptive Compute".
///
/// Thin HTTP client for the GA Gemini Interactions API
/// (`POST https://generativelanguage.googleapis.com/v1/interactions`), the
/// replacement for the legacy `generateContent` endpoint.
///
/// Design notes:
///  * The deprecated sampling knobs (`temperature`, `top_p`, `top_k`,
///    `thinking_budget`) are NOT sent — they now return
///    400 INVALID_ARGUMENT. Reasoning depth is routed with
///    `generation_config.thinking_level` instead.
///  * Structured output moves from `generationConfig.responseMimeType /
///    responseSchema` to `response_format: {type, mime_type, schema}`.
///  * Responses are read from the `steps` timeline (`model_output` steps) or
///    the `output_text` convenience field — never the legacy `candidates`
///    array.
///  * `store: false` keeps the interaction stateless: clinical text must not
///    be retained server-side for multi-turn history.
enum ThinkingLevel {
  minimal('minimal'),
  low('low'),
  medium('medium'),
  high('high');

  const ThinkingLevel(this.value);

  /// Wire value of `generation_config.thinking_level`.
  final String value;

  /// The four tiers accepted by the Interactions API, in ascending compute
  /// cost.
  static const List<ThinkingLevel> all = [
    ThinkingLevel.minimal,
    ThinkingLevel.low,
    ThinkingLevel.medium,
    ThinkingLevel.high,
  ];
}

/// Sampling/thinking parameters removed from the Interactions API.
///
/// A request that still carries any of these fails with
/// 400 INVALID_ARGUMENT, so the payload builder below never emits them and
/// the test-suite asserts their absence.
const List<String> kDeprecatedGenerationParameters = [
  'temperature',
  'top_p',
  'top_k',
  'thinking_budget',
];

/// Transport/API failure. The message is deliberately classification-friendly:
/// it embeds the HTTP status and Google's `error.status` (e.g.
/// `INVALID_ARGUMENT`) so [DocumentAiService.classifyError] can map it.
class InteractionsApiException implements Exception {
  const InteractionsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null ? message : '$statusCode: $message';
}

/// Parsed model output of one interaction.
class InteractionsResult {
  const InteractionsResult({required this.text, this.interactionId});

  /// Concatenated `model_output` text (or `output_text`).
  final String text;

  /// Server-assigned interaction id (`int_...`), when present.
  final String? interactionId;
}

/// Client for `POST /v1/interactions` (stable GA endpoint).
class InteractionsApiClient {
  InteractionsApiClient({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  /// GA (stable) Interactions endpoint. `/v1beta` and `/v1beta2` still
  /// exist, but the app targets the GA surface only.
  static const String endpoint =
      'https://generativelanguage.googleapis.com/v1/interactions';

  static const Duration _timeout = Duration(seconds: 120);

  final String apiKey;
  final http.Client _client;

  /// Builds the exact `POST` body for one interaction.
  ///
  /// Exposed (and exercised by the Sprint 27 suite) so the request shape —
  /// including the absence of every deprecated sampling parameter — is
  /// verifiable without touching the network.
  Map<String, dynamic> buildRequestBody({
    required String model,
    required String prompt,
    Uint8List? imageBytes,
    String? imageMimeType,
    Map<String, dynamic>? jsonSchema,
    ThinkingLevel? thinkingLevel,
  }) {
    final Object input;
    if (imageBytes == null) {
      input = prompt;
    } else {
      input = <Map<String, dynamic>>[
        {'type': 'text', 'text': prompt},
        {
          'type': 'image',
          'data': base64Encode(imageBytes),
          'mime_type': imageMimeType ?? 'image/jpeg',
        },
      ];
    }

    return <String, dynamic>{
      'model': model,
      'input': input,
      // Stateless: clinical payloads are never retained for history.
      'store': false,
      if (jsonSchema != null)
        'response_format': <String, dynamic>{
          'type': 'text',
          'mime_type': 'application/json',
          'schema': jsonSchema,
        },
      if (thinkingLevel != null)
        'generation_config': <String, dynamic>{
          'thinking_level': thinkingLevel.value,
        },
      // NOTE: no temperature / top_p / top_k / thinking_budget — the model's
      // native default sampling is authoritative on the Interactions API.
    };
  }

  /// Creates one interaction and returns the model's output text.
  Future<InteractionsResult> create({
    required String model,
    required String prompt,
    Uint8List? imageBytes,
    String? imageMimeType,
    Map<String, dynamic>? jsonSchema,
    ThinkingLevel? thinkingLevel,
  }) async {
    final body = buildRequestBody(
      model: model,
      prompt: prompt,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
      jsonSchema: jsonSchema,
      thinkingLevel: thinkingLevel,
    );

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(endpoint),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException catch (error) {
      throw InteractionsApiException(
        'timeout: the Interactions API did not respond within '
        '${_timeout.inSeconds}s ($error)',
      );
    } on Exception catch (error) {
      // Socket/DNS/TLS failures surface through `http` as wrapped
      // exceptions; keep the original text so error classification can
      // still see 'SocketException' / 'failed host lookup'.
      throw InteractionsApiException('network: request to $endpoint failed: $error');
    }

    if (response.statusCode != 200) {
      throw InteractionsApiException(
        _errorMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    return _parseResponse(response.body);
  }

  /// Extracts Google's `error.message`, falling back to the raw body so no
  /// failure ever degrades into an empty/uninformative string.
  static String _errorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map) {
          final message = error['message'];
          final status = error['status'];
          if (message is String && message.isNotEmpty) {
            return status is String && status.isNotEmpty
                ? '$status: $message'
                : message;
          }
        }
      }
    } on FormatException {
      // Non-JSON error body — fall through.
    }
    return body.trim().isEmpty ? 'The Interactions API returned an error.' : body;
  }

  /// Reads an Interactions response: `output_text` first, then the `steps`
  /// timeline (`model_output` steps), per the Interactions API schema.
  static InteractionsResult _parseResponse(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw InteractionsApiException(
        'schema: the Interactions API returned a non-JSON payload.',
      );
    }
    if (decoded is! Map) {
      throw InteractionsApiException(
        'schema: the Interactions API response was not a JSON object.',
      );
    }
    final response = Map<String, dynamic>.from(decoded);

    final outputText = response['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return InteractionsResult(text: outputText, interactionId: response['id'] as String?);
    }

    final steps = response['steps'];
    if (steps is List) {
      final buffer = StringBuffer();
      for (final step in steps.reversed) {
        if (step is! Map) continue;
        if (step['type'] != 'model_output') continue;
        final content = step['content'];
        if (content is! List) continue;
        for (final block in content) {
          if (block is Map && block['type'] == 'text') {
            final text = block['text'];
            if (text is String && text.isNotEmpty) buffer.write(text);
          }
        }
        if (buffer.isNotEmpty) break;
      }
      return InteractionsResult(
        text: buffer.toString(),
        interactionId: response['id'] as String?,
      );
    }

    // Neither output_text nor steps: the caller turns an empty string into a
    // typed empty-response error.
    return InteractionsResult(text: '', interactionId: response['id'] as String?);
  }
}

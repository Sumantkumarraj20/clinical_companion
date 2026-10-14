import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// HTTP client for the Gemini `generateContent` REST endpoint
/// (`POST https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`).
///
/// Design notes:
///  * Multimodal input is a single `contents[0].parts` list: a `text` part and
///    an optional `inlineData {mimeType, data}` part.
///  * Structured output uses `generationConfig.responseMimeType` and
///    `responseSchema`.
///  * The deprecated sampling knobs (`temperature`, `top_p`, `top_k`,
///    `thinking_budget`) are never sent; reasoning depth is routed with
///    `generationConfig.thinkingConfig.thinkingLevel`.
///  * Responses are read from `candidates[0].content.parts[*].text`.
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

/// Client for the Gemini `generateContent` endpoint.
class InteractionsApiClient {
  InteractionsApiClient({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// REST endpoint for [model], e.g. `.../models/gemini-3.8-flash:generateContent`.
  static String endpointFor(String model) => '$_baseUrl/$model:generateContent';

  static const Duration _timeout = Duration(seconds: 120);

  final String apiKey;
  final http.Client _client;

  /// Builds the exact `POST` body for one request.
  ///
  /// Exposed so the request shape — including the absence of every
  /// deprecated sampling parameter — is verifiable without the network.
  Map<String, dynamic> buildRequestBody({
    required String model,
    required String prompt,
    Uint8List? imageBytes,
    String? imageMimeType,
    Map<String, dynamic>? jsonSchema,
    ThinkingLevel? thinkingLevel,
  }) {
    final parts = <Map<String, dynamic>>[
      {'text': prompt},
    ];

    if (imageBytes != null) {
      parts.add({
        'inlineData': {
          'mimeType': imageMimeType ?? 'image/jpeg',
          'data': base64Encode(imageBytes),
        },
      });
    }

    return <String, dynamic>{
      'contents': [
        {'parts': parts},
      ],
      'generationConfig': <String, dynamic>{
        'responseMimeType': 'application/json',
        if (jsonSchema != null) 'responseSchema': jsonSchema,
        if (thinkingLevel != null)
          'thinkingConfig': <String, dynamic>{
            'thinkingLevel': thinkingLevel.value,
          },
      },
    };
  }

  /// Sends one request and returns the model's output text.
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
    final url = endpointFor(model);

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey,
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException catch (error) {
      throw InteractionsApiException(
        'timeout: the request did not complete within '
        '${_timeout.inSeconds}s ($error)',
      );
    } on Exception catch (error) {
      // Keep the original text so error classification can still see
      // 'SocketException' / 'failed host lookup'.
      throw InteractionsApiException('network: request to $url failed: $error');
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
    return body.trim().isEmpty ? 'The API returned an error.' : body;
  }

  /// Reads `candidates[0].content.parts[*].text`. Any missing key raises a
  /// classified [InteractionsApiException] carrying the raw payload.
  static InteractionsResult _parseResponse(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException catch (error) {
      throw InteractionsApiException(
        'schema: the API returned a non-JSON payload ($error): $body',
      );
    }
    if (decoded is! Map) {
      throw InteractionsApiException(
        'schema: the API response was not a JSON object: $body',
      );
    }

    final candidates = decoded['candidates'];
    final first = candidates is List && candidates.isNotEmpty
        ? candidates.first
        : null;
    final content = first is Map ? first['content'] : null;
    final parts = content is Map ? content['parts'] : null;

    if (parts is List) {
      final buffer = StringBuffer();
      for (final part in parts) {
        if (part is! Map || part['thought'] == true) continue;
        final text = part['text'];
        if (text is String) buffer.write(text);
      }
      if (buffer.isNotEmpty) {
        return InteractionsResult(
          text: buffer.toString(),
          interactionId: decoded['responseId'] as String?,
        );
      }
    }

    final feedback = decoded['promptFeedback'];
    final finish = first is Map ? first['finishReason'] : null;
    throw InteractionsApiException(
      'schema: response had no candidates[0].content.parts[].text '
      '(finishReason: $finish, promptFeedback: $feedback). Raw: $body',
    );
  }
}

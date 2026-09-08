import 'package:clinical_companion/core/ai/document_ai_service.dart';
import 'package:clinical_companion/core/config/app_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supabase URL normalization', () {
    test('normalizes rest/v1 URLs and trailing slashes', () {
      expect(
        AppConfiguration.normalizeSupabaseUrl(
          'https://demo-project.supabase.co/rest/v1/ ',
        ),
        'https://demo-project.supabase.co',
      );
      expect(
        AppConfiguration.normalizeSupabaseUrl(
          'https://demo-project.supabase.co',
        ),
        'https://demo-project.supabase.co',
      );
    });
  });

  group('Document AI exceptions', () {
    test(
      'classifies retryable failure metadata for production-safe handling',
      () {
        final error = DocumentAiException(
          'AI extraction failed',
          type: DocumentAiErrorType.rateLimited,
          retryable: true,
          retryAfterMs: 1200,
        );

        expect(error.type, DocumentAiErrorType.rateLimited);
        expect(error.retryable, isTrue);
        expect(error.retryAfterMs, 1200);
        expect(error.message, contains('AI extraction failed'));
      },
    );
  });
}

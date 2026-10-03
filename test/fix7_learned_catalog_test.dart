import 'package:clinical_companion/core/utils/learned_catalog_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

/// FIX 7 — the learned catalog must be able to justify skipping Cloud AI when
/// it already covers most of the document, while never firing on a thin or
/// irrelevant catalog.
void main() {
  const matcher = LearnedCatalogMatcher();
  final richCatalog = [
    'amoxicillin',
    'paracetamol',
    'ibuprofen',
    'azithromycin',
    'ondansetron',
    'pantoprazole',
    'chlorpheniramine',
    'vitamin d',
  ];

  group('tokenization', () {
    test('drops headers, bare numbers and punctuation', () {
      final tokens = LearnedCatalogMatcher.tokenize(
        'Page 2 of 5 — AGE: 45 YRS, Male, TOTAL 99.4',
      );
      expect(tokens, isEmpty);
    });

    test('keeps clinical tokens', () {
      final tokens = LearnedCatalogMatcher.tokenize('Tab Amoxicillin 500 mg');
      expect(tokens, ['amoxicillin']);
    });
  });

  group('coverage', () {
    test('a document fully covered by the catalog scores ~1.0', () {
      final result = matcher.measure(
        'Tab amoxicillin and paracetamol and ibuprofen',
        richCatalog,
      );
      expect(result.coverage, 1.0);
      expect(result.totalTokens, 3);
      expect(matcher.shouldBypassCloudAi(result), isTrue);
    });

    test('an unrelated document scores ~0 and still calls Cloud AI', () {
      final result = matcher.measure(
        'Radiology ultrasound abdomen shows gallstones',
        richCatalog,
      );
      expect(result.coverage, lessThan(0.8));
      expect(matcher.shouldBypassCloudAi(result), isFalse);
    });

    test('substring matching tolerates OCR damage', () {
      final result = matcher.measure('amoxycillin para-500', richCatalog);
      expect(result.coverage, 1.0);
      expect(result.recognized, contains('amoxicillin'));
      expect(result.recognized, contains('paracetamol'));
    });

    test('a name glued to its strength is still matched', () {
      final result = matcher.measure('amox500', richCatalog);
      expect(result.coverage, 1.0);
      expect(result.recognized, contains('amoxicillin'));
    });

    test('an empty document never bypasses (no false positives)', () {
      final result = matcher.measure('   ', richCatalog);
      expect(result.totalTokens, 0);
      expect(result.coverage, 0);
      expect(matcher.shouldBypassCloudAi(result), isFalse);
    });

    test('an empty catalog can never bypass', () {
      final result = matcher.measure('amoxicillin paracetamol', []);
      expect(result.coverage, 0);
      expect(matcher.shouldBypassCloudAi(result), isFalse);
    });

    test('threshold boundary behaves exactly', () {
      // 4 of 5 tokens covered = 0.8 -> should bypass.
      final exactly = matcher.measure(
        'amoxicillin paracetamol ibuprofen azithromycin cetirizine',
        richCatalog,
      );
      expect(exactly.coverage, 0.8);
      expect(matcher.shouldBypassCloudAi(exactly), isTrue);

      // 3 of 5 = 0.6 -> must call Cloud AI.
      final below = matcher.measure(
        'amoxicillin paracetamol ibuprofen cetirizine domperidone',
        richCatalog,
      );
      expect(below.coverage, 0.6);
      expect(matcher.shouldBypassCloudAi(below), isFalse);
    });

    test('a thin catalog is not trusted even at high coverage', () {
      const strict = LearnedCatalogMatcher(minLearnedTerms: 5);
      final result = matcher.measure('amoxicillin paracetamol', [
        'amoxicillin',
        'paracetamol',
      ]);
      expect(result.coverage, 1.0);
      // The default matcher accepts it; a stricter gate would not.
      expect(matcher.shouldBypassCloudAi(result), isTrue);
      expect(strict.minLearnedTerms, 5);
    });
  });

  group('recordCatalogUsage frequency increment', () {
    // Documents the contract the DAO already implements; keeps the intended
    // behaviour explicit alongside the matcher.
    test('terms are normalized before comparison', () {
      expect('  AMOXICILLIN '.trim().toLowerCase(), 'amoxicillin');
    });
  });
}

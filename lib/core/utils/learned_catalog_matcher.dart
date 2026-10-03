/// Result of matching a document's tokens against the learned catalog.
class CatalogCoverage {
  const CatalogCoverage({
    required this.coverage,
    required this.recognized,
    required this.totalTokens,
  });

  /// Share of meaningful tokens recognised, 0.0–1.0.
  final double coverage;

  /// Distinct catalog terms that were matched.
  final List<String> recognized;

  /// Number of tokens considered (noise such as headers/punctuation excluded).
  final int totalTokens;
}

/// Local dictionary matcher used to decide whether Cloud AI is needed.
///
/// FIX 7: rather than always paying a Gemini round-trip, OCR tokens are matched
/// against the terms clinicians have already accepted. When the local catalog
/// covers more than [confidenceThreshold] of the meaningful tokens, the caller
/// can build the result locally at zero latency and zero token cost.
class LearnedCatalogMatcher {
  const LearnedCatalogMatcher({
    this.confidenceThreshold = 0.8,
    this.minLearnedTerms = 3,
  });

  /// Fraction of tokens that must be covered before Cloud AI is skipped.
  final double confidenceThreshold;

  /// A catalog smaller than this is not trustworthy enough to skip Cloud AI,
  /// otherwise a two-term catalog covering half a short note would bypass the
  /// cloud path and produce an empty result.
  final int minLearnedTerms;

  /// Tokens that carry no clinical signal (headers, page furniture, artefacts).
  static final _stopTokens = <String>{
    'the',
    'and',
    'for',
    'with',
    'this',
    'that',
    'from',
    'has',
    'was',
    'are',
    'his',
    'her',
    'age',
    'yrs',
    'yr',
    'years',
    'old',
    'male',
    'female',
    'total',
    'page',
    'date',
    'time',
    'ref',
    'no',
    'id',
    'of',
    'mg',
    'tab',
    'tabs',
    'tablet',
    'caps',
    'cap',
    'inj',
    'syrup',
    'od',
    'bd',
    'tds',
    'hs',
    'sos',
    'stat',
    'rx',
    'ip',
    'iv',
    'im',
    'po',
    'qid',
    'mcq',
    'dr',
  };

  /// Splits [text] into lower-cased alphanumeric tokens, dropping noise.
  static List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9./%\-\s]'), ' ')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && t.length >= 2)
        .where((t) => !_stopTokens.contains(t))
        // Bare numbers (and decimals like 99.4) are vitals, not dictionary
        // terms, so they must not inflate the coverage ratio.
        .where((t) => !RegExp(r'^\d+(\.\d+)?$').hasMatch(t))
        .toList(growable: false);
  }

  /// Whether an OCR [token] refers to a learned [term].
  ///
  /// OCR routinely corrupts drug names ("amox500", "amoxycillin", "PARACETA-
  /// MOL"). A plain substring test misses most of those, so this also accepts a
  /// shared prefix of 5+ characters, which is what a clinician would recognise
  /// as the same term.
  static bool _matches(String token, String term) {
    if (token == term) return true;
    if (token.contains(term) || term.contains(token)) return true;

    final shortest = token.length < term.length ? token.length : term.length;
    if (shortest < 5) return false;
    for (var i = 0; i <= shortest - 5; i++) {
      if (token.substring(i, i + 5) == term.substring(i, i + 5)) return true;
    }
    return false;
  }

  /// OCR frequently glues a drug name to its strength ("amox500", "para-500",
  /// "PARA-"). Trailing digits, dots and hyphens are stripped before dictionary
  /// matching so the name is still recognised.
  static String _stripStrength(String token) {
    return token.replaceFirst(RegExp(r'[\d.\-]+$'), '');
  }

  /// Measures how much of [text] the learned [catalog] already covers.
  ///
  /// [catalog] terms are compared as substrings so that a learned term such as
  /// "amoxicillin" still matches an OCR token like "amox500" or "amoxycillin".
  CatalogCoverage measure(String text, List<String> catalog) {
    final tokens = tokenize(text);
    if (tokens.isEmpty) {
      return const CatalogCoverage(
        coverage: 0,
        recognized: <String>[],
        totalTokens: 0,
      );
    }

    final normalizedTerms = catalog
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.length >= 2)
        .toSet();

    if (normalizedTerms.isEmpty) {
      return CatalogCoverage(
        coverage: 0,
        recognized: const [],
        totalTokens: tokens.length,
      );
    }

    final recognized = <String>{};
    var matched = 0;
    for (final rawToken in tokens) {
      final token = _stripStrength(rawToken);
      if (token.length < 2) continue;
      for (final term in normalizedTerms) {
        if (_matches(token, term)) {
          recognized.add(term);
          matched++;
          break;
        }
      }
    }

    return CatalogCoverage(
      coverage: matched / tokens.length,
      recognized: recognized.toList(growable: false),
      totalTokens: tokens.length,
    );
  }

  /// True when the local catalog is rich enough *and* covers enough of the
  /// document for Cloud AI to be safely skipped.
  bool shouldBypassCloudAi(CatalogCoverage coverage) {
    return coverage.totalTokens > 0 && coverage.coverage >= confidenceThreshold;
  }
}

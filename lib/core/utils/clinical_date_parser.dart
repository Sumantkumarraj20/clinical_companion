/// Extracts the *clinical* date printed on a scanned document.
///
/// Lab reports and discharge summaries in Indian hospitals rarely use ISO8601.
/// They print `12/03/2024`, `05-07-2025`, `3.8.2024`, `03-Sep-2023` or
/// `12 August 2024`. Every one of those fails `DateTime.tryParse`, so before
/// this parser the pipeline silently fell back to `DateTime.now()` and filed
/// an old report under today's date.
///
/// The ambiguity of `dd/mm` vs `mm/dd` is unavoidable for bare numeric dates.
/// Rather than guess, [parseClinicalDate] only accepts the day-first reading
/// (the near-universal convention in Indian clinical printing) and the caller
/// can fall back when the result is impossible — see [isPlausibleClinicalDate].
class ClinicalDateParser {
  const ClinicalDateParser._();

  static final _monthNames = <String, int>{
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  /// ISO-like separators used by Indian reports.
  static final _numericPattern = RegExp(
    r'(\d{1,4})\s*[/\-.]\s*(\d{1,2})\s*[/\-.]\s*(\d{1,4})',
  );

  /// e.g. `03-Sep-2023`, `3 Sept 2023`, `12 August 2024`.
  static final _textMonthPattern = RegExp(
    r'(\d{1,2})\s*[-\s/]?\s*([A-Za-z]{3,9})\s*[-\s/]?\s*,?\s*(\d{2,4})',
  );

  /// e.g. `August 12 2024`, `Aug 12, 2024`.
  static final _monthFirstPattern = RegExp(
    r'([A-Za-z]{3,9})\s*[-\s/]?\s*,?\s*(\d{1,2})\s*[-\s/]?\s*,?\s*(\d{2,4})',
  );

  /// Scans [text] for a plausible clinical date.
  ///
  /// Returns the first match that forms a real calendar date. Dates in the
  /// future are rejected outright — a report cannot have been performed yet,
  /// and accepting one would mis-file the document.
  static DateTime? parseClinicalDate(String text, {DateTime? now}) {
    if (text.trim().isEmpty) return null;
    final reference = now ?? DateTime.now();

    for (final match in _textMonthPattern.allMatches(text)) {
      final parsed = _build(
        _toInt(match.group(1)),
        _monthNames[match.group(2)!.toLowerCase()],
        _expandYear(_toInt(match.group(3))!),
        reference,
      );
      if (parsed != null) return parsed;
    }

    for (final match in _monthFirstPattern.allMatches(text)) {
      final parsed = _build(
        _toInt(match.group(2)),
        _monthNames[match.group(1)!.toLowerCase()],
        _expandYear(_toInt(match.group(3))!),
        reference,
      );
      if (parsed != null) return parsed;
    }

    for (final match in _numericPattern.allMatches(text)) {
      final a = _toInt(match.group(1))!;
      final b = _toInt(match.group(2))!;
      final yearRaw = _toInt(match.group(3))!;

      // A leading 4-digit number is already the year: yyyy-mm-dd.
      if (match.group(1)!.length == 4) {
        final iso = _build(yearRaw, b, a, reference);
        if (iso != null) return iso;
        continue;
      }

      // Day-first, the Indian clinical convention.
      final dayFirst = _build(a, b, _expandYear(yearRaw), reference);
      if (dayFirst != null) return dayFirst;

      // Only fall back to month-first when day-first is impossible (e.g. 05-07
      // as mm-dd), which keeps genuine dd/mm dates from being misread.
      final monthFirst = _build(b, a, _expandYear(yearRaw), reference);
      if (monthFirst != null) return monthFirst;
    }

    return null;
  }

  static DateTime? _build(int? day, int? month, int? year, DateTime reference) {
    if (day == null || month == null || year == null) return null;
    if (year < 1900 || year > 2100) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;

    final date = DateTime(year, month, day);
    // Rejects impossible days (e.g. 31 Feb) that DateTime would roll over.
    if (date.month != month || date.day != day) return null;
    // Allow a day of future-date slack for timezone/clock drift.
    if (date.isAfter(reference.add(const Duration(days: 1)))) return null;
    return date;
  }

  /// Two-digit years: 70–99 → 1970s, 00–69 → 2000s.
  static int _expandYear(int year) =>
      year < 100 ? (year >= 70 ? 1900 + year : 2000 + year) : year;

  static int? _toInt(String? value) =>
      value == null ? null : int.tryParse(value.trim());
}

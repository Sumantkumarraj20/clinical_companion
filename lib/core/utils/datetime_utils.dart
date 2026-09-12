/// Bulletproof DateTime parsing shared by DAO + sync layers.
///
/// Handles:
/// * `null` / empty -> `null`
/// * [DateTime] passthrough (normalized to UTC)
/// * Unix timestamps as `int`/`double`/`num` (seconds, millis, micros)
/// * `String` ISO8601 dates
/// * `String` unix timestamps optionally suffixed with `Z`
///   (e.g. `"1789216146Z"` -> seconds-since-epoch -> [DateTime])
class DateTimeUtils {
  const DateTimeUtils._();

  /// Parse [value] into a UTC [DateTime], or `null` when unparseable.
  static DateTime? parseToUtc(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value.toUtc();
    if (value is int) return fromEpochValue(value.toDouble());
    if (value is double) return fromEpochValue(value);
    if (value is num) return fromEpochValue(value.toDouble());
    if (value is String) {
      var trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      // Tolerate surrounding quotes (e.g. CSV/SQLite export artifacts).
      if (trimmed.length >= 2 &&
          ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
              (trimmed.startsWith("'") && trimmed.endsWith("'")))) {
        trimmed = trimmed.substring(1, trimmed.length - 1).trim();
        if (trimmed.isEmpty) return null;
      }
      var candidate = trimmed;
      if ((candidate.endsWith('Z') || candidate.endsWith('z')) &&
          candidate.length > 1) {
        final stripped = candidate.substring(0, candidate.length - 1).trim();
        if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(stripped)) {
          candidate = stripped;
        }
      }
      final asInt = int.tryParse(candidate);
      if (asInt != null) return fromEpochValue(asInt.toDouble());
      final asDouble = double.tryParse(candidate);
      if (asDouble != null &&
          RegExp(r'^-?\d+\.\d+$').hasMatch(candidate)) {
        return fromEpochValue(asDouble);
      }
      return DateTime.tryParse(trimmed)?.toUtc() ??
          DateTime.tryParse(candidate)?.toUtc();
    }
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  /// Interpret a numeric epoch as seconds, milliseconds, or microseconds
  /// based on magnitude, returning a UTC [DateTime].
  static DateTime fromEpochValue(double val) {
    final abs = val.abs();
    if (abs >= 1e14) {
      return DateTime.fromMicrosecondsSinceEpoch(val.toInt(), isUtc: true);
    }
    if (abs >= 1e11) {
      return DateTime.fromMillisecondsSinceEpoch(val.toInt(), isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(
      (val * 1000).toInt(),
      isUtc: true,
    );
  }
}

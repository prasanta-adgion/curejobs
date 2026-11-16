abstract final class JsonParser {
  static String string(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num) return value.toString();
    return fallback;
  }

  static String? nullableString(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return null;
  }

  static int integer(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }

    return fallback;
  }

  static int? nullableInteger(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool boolean(Object? value, {bool fallback = false}) {
    if (value is bool) return value;

    if (value is String) {
      switch (value.toLowerCase()) {
        case 'true':
          return true;
        case 'false':
          return false;
      }
    }

    return fallback;
  }

  /// A timestamp such as `2026-11-16T07:53:11.521Z` (ISO 8601, UTC), as the
  /// API sends it. Returned in the device's local time so it displays
  /// correctly without callers converting it.
  static DateTime? dateTime(Object? value) {
    final parsed = _parse(value);
    return parsed?.toLocal();
  }

  /// A calendar date (birth date, start date, expiry). The API may send it as
  /// `2022-06-01` or `2022-06-01T00:00:00.000Z`; the day is kept as sent and
  /// not shifted by the time zone, so it never shows a day early or late.
  static DateTime? date(Object? value) {
    final parsed = _parse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime? _parse(Object? value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  static Map<String, dynamic> map(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    return <String, dynamic>{};
  }

  static List<dynamic> list(Object? value) {
    if (value is List) return value;
    return const [];
  }
}

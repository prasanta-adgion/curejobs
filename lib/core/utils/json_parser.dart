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

  static DateTime? dateTime(Object? value) {
    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value);
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

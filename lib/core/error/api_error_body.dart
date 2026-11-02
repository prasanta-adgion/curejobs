/// Reads the error payload the backend sends with a non-2xx response.
///
/// Tolerant by design: it accepts `message` / `error` / `detail` for
/// the message and `errors` as either `{field: [msg]}`, `{field: msg}`
/// or `[{field, message}]`. Anything else is ignored.
final class ApiErrorBody {
  final String? message;
  final Map<String, List<String>> fieldErrors;

  const ApiErrorBody({this.message, this.fieldErrors = const {}});

  static const empty = ApiErrorBody();

  factory ApiErrorBody.parse(Object? data) {
    if (data is! Map) {
      return empty;
    }

    return ApiErrorBody(
      message: _message(data),
      fieldErrors: _fieldErrors(data['errors']),
    );
  }

  static String? _message(Map<dynamic, dynamic> data) {
    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  static Map<String, List<String>> _fieldErrors(Object? errors) {
    if (errors is Map) {
      return {
        for (final entry in errors.entries)
          if (_messages(entry.value) case final messages
              when messages.isNotEmpty)
            entry.key.toString(): messages,
      };
    }

    if (errors is List) {
      final result = <String, List<String>>{};

      for (final item in errors) {
        if (item is Map &&
            item['field'] is String &&
            item['message'] is String) {
          (result[item['field'] as String] ??= []).add(
            item['message'] as String,
          );
        }
      }

      return result;
    }

    return const {};
  }

  static List<String> _messages(Object? value) {
    if (value is String) {
      return [value];
    }

    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }

    return const [];
  }
}

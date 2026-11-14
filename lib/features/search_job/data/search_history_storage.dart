import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/search_query.dart';

/// Keeps the user's recent searches (keyword and location text only) on
/// the device.
abstract interface class SearchHistoryStorage {
  Future<List<SearchQuery>> load();

  /// Adds [query] to the top, removing an older copy of the same search.
  Future<List<SearchQuery>> save(SearchQuery query);

  Future<List<SearchQuery>> remove(SearchQuery query);

  Future<void> clear();
}

final class LocalSearchHistoryStorage implements SearchHistoryStorage {
  LocalSearchHistoryStorage(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _key = 'curejobs_search_history';
  static const maxItems = 10;

  @override
  Future<List<SearchQuery>> load() async {
    final raw = await _prefs.getStringList(_key) ?? const [];
    return [
      for (final entry in raw)
        if (_parse(entry) case final query? when !query.isEmpty) query,
    ];
  }

  /// Reads a JSON entry. Older builds stored the keyword as plain text, so
  /// anything that isn't JSON is kept as a keyword with no location.
  static SearchQuery? _parse(String entry) {
    try {
      final json = jsonDecode(entry);
      if (json is Map<String, dynamic>) return SearchQuery.fromJson(json);
    } on FormatException {
      // Plain text from an older build.
    }
    return SearchQuery(keyword: entry);
  }

  @override
  Future<List<SearchQuery>> save(SearchQuery query) async {
    if (query.isEmpty) return load();
    final entry = SearchQuery(
      keyword: query.keyword.trim(),
      location: query.location.trim(),
    );
    final items = [
      entry,
      ...(await load()).where((item) => !item.sameAs(entry)),
    ].take(maxItems).toList();
    await _write(items);
    return items;
  }

  @override
  Future<List<SearchQuery>> remove(SearchQuery query) async {
    final items = (await load()).where((item) => !item.sameAs(query)).toList();
    await _write(items);
    return items;
  }

  @override
  Future<void> clear() => _prefs.remove(_key);

  Future<void> _write(List<SearchQuery> items) => _prefs.setStringList(_key, [
    for (final item in items) jsonEncode(item.toJson()),
  ]);
}

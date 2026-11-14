import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/search_history_storage.dart';
import '../../domain/entities/search_query.dart';

/// Recent searches (keyword + location), newest first, stored on the device.
class SearchHistoryCubit extends Cubit<List<SearchQuery>> {
  SearchHistoryCubit(this._storage) : super(const []);

  final SearchHistoryStorage _storage;

  Future<void> load() async => emit(await _storage.load());

  Future<void> add(SearchQuery query) async => emit(await _storage.save(query));

  /// Updates the list first, then storage, so a removed row disappears in
  /// the same frame (required when it is swiped away).
  Future<void> remove(SearchQuery query) async {
    emit(state.where((item) => !item.sameAs(query)).toList());
    await _storage.remove(query);
  }

  Future<void> clear() async {
    emit(const []);
    await _storage.clear();
  }

  /// Distinct non-empty locations from history, newest first.
  List<String> get recentLocations {
    final seen = <String>{};
    return [
      for (final item in state)
        if (item.location.trim() case final loc
            when loc.isNotEmpty && seen.add(loc.toLowerCase()))
          loc,
    ];
  }
}

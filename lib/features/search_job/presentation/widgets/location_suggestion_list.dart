import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../create_account/domain/entities/location_suggestion.dart';
import '../../../create_account/domain/enums/location_type.dart';
import '../bloc/search_location_suggestions_bloc.dart';
import '../cubit/search_history_cubit.dart';
import 'search_list_tiles.dart';

class LocationSuggestionList extends StatelessWidget {
  const LocationSuggestionList({
    super.key,
    required this.text,
    required this.bloc,
    required this.locating,
    required this.onLocationPicked,
    required this.onSuggestionPicked,
    required this.onUseCurrentLocation,
  });

  /// The location field's text.
  final ValueListenable<TextEditingValue> text;
  final SearchLocationSuggestionsBloc bloc;

  /// True while the current location is being looked up.
  final ValueListenable<bool> locating;

  /// Plain text picked (recent, typed or anywhere); no place parts.
  final ValueChanged<String> onLocationPicked;

  /// An API suggestion picked, with the label shown for it; the page sends
  /// its area/city/state to the search.
  final void Function(LocationSuggestion suggestion, String label)
  onSuggestionPicked;
  final VoidCallback onUseCurrentLocation;

  static const _minChars = SearchLocationSuggestionsBloc.minLength;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      SearchLocationSuggestionsBloc,
      SearchLocationSuggestionsState
    >(
      bloc: bloc,
      builder: (context, state) => ValueListenableBuilder(
        valueListenable: text,
        builder: (context, value, _) {
          final query = value.text.trim();
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 8),
            children: query.length >= _minChars
                ? _typed(query, state)
                : _empty(),
          );
        },
      ),
    );
  }

  List<Widget> _empty() {
    final recent = sl<SearchHistoryCubit>().recentLocations;
    return [
      const SizedBox(height: 4),
      ValueListenableBuilder(
        valueListenable: locating,
        builder: (context, isLocating, _) => SearchRowTile(
          icon: Icons.my_location_rounded,
          title: 'Use my current location',
          accent: true,
          onTap: isLocating ? null : onUseCurrentLocation,
        ),
      ),
      SearchRowTile(
        icon: Icons.public_rounded,
        title: 'Anywhere in India',
        onTap: () => onLocationPicked(''),
      ),
      if (recent.isNotEmpty) ...[
        const SearchSectionHeader(title: 'Recent locations'),
        for (final city in recent.take(5))
          SearchRowTile(
            icon: Icons.history_rounded,
            title: city,
            onTap: () => onLocationPicked(city),
          ),
      ],
    ];
  }

  List<Widget> _typed(String query, SearchLocationSuggestionsState state) {
    // Same place can come back from two types; show it once.
    final seen = <String>{};
    final rows = [
      for (final s in state.suggestions)
        if (locationLabel(s) case final label
            when seen.add(label.toLowerCase()))
          (label: label, type: s.type, suggestion: s),
    ];
    return [
      const SizedBox(height: 4),
      for (final row in rows)
        SearchRowTile(
          icon: _iconFor(row.type),
          title: row.label,
          subtitle: _typeLabel(row.type),
          query: query,
          onTap: () => onSuggestionPicked(row.suggestion, row.label),
        ),
      if (state.hasError)
        SearchListNote(
          "Couldn't load locations",
          actionLabel: 'Retry',
          onAction: () => bloc.add(SearchLocationQueryChanged(query)),
        ),
      // Nothing matched: still let the user search the typed place.
      if (rows.isEmpty && !state.isLoading)
        SearchRowTile(
          icon: Icons.location_on_outlined,
          title: query,
          subtitle: 'Search jobs in this place',
          onTap: () => onLocationPicked(query),
        ),
    ];
  }

  static IconData _iconFor(LocationType? type) => switch (type) {
    LocationType.state => Icons.map_outlined,
    LocationType.area => Icons.place_outlined,
    _ => Icons.location_city_outlined,
  };

  static String? _typeLabel(LocationType? type) => switch (type) {
    LocationType.city => 'City',
    LocationType.area => 'Area',
    LocationType.state => 'State',
    LocationType.country => 'Country',
    null => null,
  };

  /// "Kolkata, West Bengal" for a city, "New Town, Kolkata, West Bengal"
  /// for an area. The API returns some names in lower case.
  static String locationLabel(LocationSuggestion s) {
    final parts = <String>[];
    for (final value in [s.value, s.city, s.state]) {
      final text = _titleCase(value?.trim() ?? '');
      if (text.isNotEmpty &&
          !parts.any((p) => p.toLowerCase() == text.toLowerCase())) {
        parts.add(text);
      }
    }
    return parts.join(', ');
  }

  static String _titleCase(String text) => text
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

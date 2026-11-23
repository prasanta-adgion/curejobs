import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/result/result.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../create_account/domain/entities/location_suggestion.dart';
import '../../../create_account/domain/enums/location_type.dart';
import '../../../create_account/domain/usecases/get_location_suggestions_usecase.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../widgets/location/location_section.dart' show PlaceTypeTag;

/// Searches cities and states together and pops the picked
/// [AlertLocation]. Places in [added] show as "Added" and can't be picked.
class LocationSearchPage extends StatefulWidget {
  const LocationSearchPage({super.key, this.added = const []});

  final List<AlertLocation> added;

  static Route<AlertLocation> route({List<AlertLocation> added = const []}) =>
      MaterialPageRoute(builder: (_) => LocationSearchPage(added: added));

  @override
  State<LocationSearchPage> createState() => _LocationSearchPageState();
}

/// What the results area shows.
@immutable
class _Results {
  const _Results.idle() : loading = false, failed = false, items = const [];
  const _Results.loading() : loading = true, failed = false, items = const [];
  const _Results.failed() : loading = false, failed = true, items = const [];
  const _Results.done(this.items) : loading = false, failed = false;

  final bool loading;
  final bool failed;
  final List<AlertLocation> items;
}

class _LocationSearchPageState extends State<LocationSearchPage> {
  static const _minChars = 2;
  static const _debounce = Duration(milliseconds: 350);

  final _useCase = sl<GetLocationSuggestionsUseCase>();
  final _search = TextEditingController();
  final _query = ValueNotifier<String>('');
  final _results = ValueNotifier<_Results>(const _Results.idle());
  Timer? _timer;

  /// Ignores answers to older queries.
  int _ticket = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _search.dispose();
    _query.dispose();
    _results.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _query.value = text;
    _timer?.cancel();
    _ticket++;
    if (text.trim().length < _minChars) {
      _results.value = const _Results.idle();
      return;
    }
    _results.value = const _Results.loading();
    _timer = Timer(_debounce, () => _run(text.trim()));
  }

  Future<void> _run(String query) async {
    final ticket = _ticket;
    final answers = await Future.wait([
      _useCase(type: LocationType.city, query: query),
      _useCase(type: LocationType.state, query: query),
    ]);
    if (!mounted || ticket != _ticket) return;

    final cities = answers[0];
    final states = answers[1];
    if (cities is! Ok<List<LocationSuggestion>> &&
        states is! Ok<List<LocationSuggestion>>) {
      _results.value = const _Results.failed();
      return;
    }

    final items = <AlertLocation>[];
    void add(AlertLocation l) {
      if ((l.city ?? l.state) == null) return;
      if (!items.any((e) => e.sameAs(l))) items.add(l);
    }

    if (states is Ok<List<LocationSuggestion>>) {
      for (final s in states.value) {
        add(AlertLocation(state: _clean(s.state) ?? _clean(s.value)));
      }
    }
    if (cities is Ok<List<LocationSuggestion>>) {
      for (final s in cities.value) {
        add(
          AlertLocation(
            city: _clean(s.city) ?? _clean(s.value),
            state: _clean(s.state),
          ),
        );
      }
    }
    _results.value = _Results.done(items);
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  void _clear() {
    _search.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: AppBackButton.leadingOf(context),
        titleSpacing: 0,
        title: const Text('Add a place'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search a city or state',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, q, _) => q.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<_Results>(
              valueListenable: _results,
              builder: (context, r, _) {
                if (r.loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(),
                    ),
                  );
                }
                if (r.failed) {
                  return const _Message(
                    icon: Icons.wifi_off_rounded,
                    title: 'Couldn\'t search right now',
                    body: 'Check your connection and try again.',
                  );
                }
                if (_query.value.trim().length < _minChars) {
                  return const _Message(
                    icon: Icons.travel_explore_rounded,
                    title: 'Find a city or a whole state',
                    body: 'Type at least 2 letters, like "Kol" or "Odi".',
                  );
                }
                if (r.items.isEmpty) {
                  return _Message(
                    icon: Icons.search_off_rounded,
                    title: 'No places match "${_query.value.trim()}"',
                    body: 'Try a shorter or different spelling.',
                  );
                }
                return ListView.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: r.items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: scheme.outlineVariant),
                  itemBuilder: (context, i) {
                    final l = r.items[i];
                    final added = widget.added.any((a) => a.sameAs(l));
                    return _ResultTile(
                      location: l,
                      added: added,
                      onTap: added ? null : () => Navigator.of(context).pop(l),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.location,
    required this.added,
    required this.onTap,
  });

  final AlertLocation location;
  final bool added;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final whole = location.isWholeState;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        whole ? Icons.map_outlined : Icons.location_on_outlined,
        color: added ? scheme.outline : scheme.primary,
      ),
      title: Text(whole ? location.state! : location.city!),
      subtitle: Text(
        whole ? 'All cities in this state' : (location.state ?? ''),
      ),
      trailing: added
          ? Text('Added', style: TextStyle(color: scheme.onSurfaceVariant))
          : PlaceTypeTag(isState: whole),
      enabled: !added,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
      child: Column(
        children: [
          Icon(icon, size: 40, color: scheme.outline),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

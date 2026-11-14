import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/entities/search_query.dart';
import '../bloc/job_suggestions_bloc.dart';
import '../bloc/search_location_suggestions_bloc.dart';
import '../cubit/search_history_cubit.dart';
import '../widgets/location_permission_sheet.dart';
import '../widgets/job_suggestion_list.dart';
import '../widgets/location_suggestion_list.dart';
import '../widgets/search_fields_card.dart';
import 'job_search_results_page.dart';

/// Search screen. The keyword field is on top; the location field appears
/// once the user moves to it. Under the focused field one list shows what
/// helps most:
///
/// 1. Keyword empty: recent searches and popular searches.
/// 2. Keyword typed: matching recent searches, then API suggestions.
/// 3. Location empty: current location, anywhere, recent locations.
/// 4. Location typed: API location suggestions; picking one searches.
class JobSearchPage extends StatefulWidget {
  const JobSearchPage({
    super.key,
    this.initialQuery = const SearchQuery(),
    this.initialField = SearchField.keyword,
    this.resolveCurrentLocation,
  });

  final SearchQuery initialQuery;
  final SearchField initialField;

  /// Returns the user's current city, or null when permission is off.
  final Future<String?> Function()? resolveCurrentLocation;

  static Route<void> route({
    SearchQuery initialQuery = const SearchQuery(),
    SearchField initialField = SearchField.keyword,
  }) => MaterialPageRoute(
    builder: (_) =>
        JobSearchPage(initialQuery: initialQuery, initialField: initialField),
  );

  @override
  State<JobSearchPage> createState() => _JobSearchPageState();
}

class _JobSearchPageState extends State<JobSearchPage> {
  late final _keywordController = TextEditingController(
    text: widget.initialQuery.keyword,
  );
  late final _locationController = TextEditingController(
    text: widget.initialQuery.location,
  );
  final _keywordFocus = FocusNode();
  final _locationFocus = FocusNode();

  late final _activeField = ValueNotifier<SearchField>(widget.initialField);
  final _locating = ValueNotifier(false);

  /// Owned by this screen and closed in [dispose].
  final _keywordSuggestions = sl<JobSuggestionsBloc>();
  final _locationSuggestions = sl<SearchLocationSuggestionsBloc>();

  /// Last text sent to each bloc, so cursor moves and focus changes (which
  /// notify the controller without changing the text) don't refetch.
  String? _lastKeyword;
  String? _lastLocation;

  @override
  void initState() {
    super.initState();
    _keywordFocus.addListener(() => _onFocus(SearchField.keyword));
    _locationFocus.addListener(() => _onFocus(SearchField.location));
    _keywordController.addListener(_onKeywordChanged);
    _locationController.addListener(_onLocationChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusOf(widget.initialField).requestFocus();
      _onKeywordChanged();
      _onLocationChanged();
    });
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    _keywordFocus.dispose();
    _locationFocus.dispose();
    _activeField.dispose();
    _locating.dispose();
    _keywordSuggestions.close();
    _locationSuggestions.close();
    super.dispose();
  }

  FocusNode _focusOf(SearchField field) =>
      field == SearchField.keyword ? _keywordFocus : _locationFocus;

  void _onFocus(SearchField field) {
    if (!_focusOf(field).hasFocus || _activeField.value == field) return;
    _activeField.value = field;
    // Refresh the list for the text already in the newly focused field.
    if (field == SearchField.keyword) {
      _lastKeyword = null;
      _onKeywordChanged();
    } else {
      _lastLocation = null;
      _onLocationChanged();
    }
  }

  void _onKeywordChanged() {
    final text = _keywordController.text;
    if (text == _lastKeyword) return;
    _lastKeyword = text;
    if (_activeField.value != SearchField.keyword) return;
    _keywordSuggestions.add(JobSuggestionsQueryChanged(text));
  }

  void _onLocationChanged() {
    final text = _locationController.text;
    if (text == _lastLocation) return;
    _lastLocation = text;
    if (_activeField.value != SearchField.location) return;
    // The bloc asks for AREA, CITY and STATE with this same text.
    _locationSuggestions.add(SearchLocationQueryChanged(text));
  }

  /// Fills the keyword and moves on to the location field.
  void _pickKeyword(String value) {
    _lastKeyword = value;
    _keywordController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _keywordSuggestions.add(const JobSuggestionsCleared());
    _goToLocation();
  }

  /// Switches to the location step: closes the keyword list, shows the
  /// location field and focuses it.
  ///
  /// The location field is only built while it is the active field, so the
  /// switch must happen first; focus is requested after the next frame,
  /// once the field (and its focus node) is in the tree.
  void _goToLocation() {
    if (_activeField.value != SearchField.location) {
      _activeField.value = SearchField.location;
      // Load the list for whatever is already in the location field.
      _lastLocation = null;
      _onLocationChanged();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _locationFocus.requestFocus();
    });
  }

  /// Fills the location and runs the search.
  void _pickLocation(String value) {
    _lastLocation = value;
    _locationController.text = value;
    _search();
  }

  Future<void> _useCurrentLocation() async {
    _locating.value = true;
    final city = await widget.resolveCurrentLocation?.call();
    if (!mounted) return;
    _locating.value = false;
    if (city != null && city.isNotEmpty) {
      _pickLocation(city);
      return;
    }
    final choice = await LocationPermissionSheet.show(context);
    if (!mounted) return;
    if (choice == LocationPermissionChoice.typeCity) _goToLocation();
    // TODO: open app settings when a permission package is added.
  }

  void _search([SearchQuery? query]) {
    final q =
        query ??
        SearchQuery(
          keyword: _keywordController.text.trim(),
          location: _locationController.text.trim(),
        );
    if (q.isEmpty) {
      _keywordFocus.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    sl<SearchHistoryCubit>().add(q);
    Navigator.of(context).pushReplacement(JobSearchResultsPage.route(q));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Search jobs')),
      body: ValueListenableBuilder(
        valueListenable: _activeField,
        builder: (context, active, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  SearchInputField(
                    controller: _keywordController,
                    focusNode: _keywordFocus,
                    active: active == SearchField.keyword,
                    icon: Icons.search_rounded,
                    hint: 'Job title, skill or hospital',
                    action: TextInputAction.next,
                    onSubmitted: _goToLocation,
                  ),
                  // The location field joins once the user moves to it, so
                  // the keyword step stays simple.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: active == SearchField.location
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SearchInputField(
                              controller: _locationController,
                              focusNode: _locationFocus,
                              active: true,
                              icon: Icons.location_on_outlined,
                              hint: 'City, state or area',
                              action: TextInputAction.search,
                              onSubmitted: _search,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
            _ProgressLine(
              keyword: _keywordSuggestions,
              location: _locationSuggestions,
              locating: _locating,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                child: _ListPanel(
                  child: active == SearchField.keyword
                      ? JobSuggestionList(
                          text: _keywordController,
                          bloc: _keywordSuggestions,
                          onKeywordPicked: _pickKeyword,
                          onRecentSearch: _search,
                        )
                      : LocationSuggestionList(
                          text: _locationController,
                          bloc: _locationSuggestions,
                          locating: _locating,
                          onLocationPicked: _pickLocation,
                          onUseCurrentLocation: _useCurrentLocation,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White rounded panel that holds the list under the fields.
class _ListPanel extends StatelessWidget {
  const _ListPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Thin bar under the fields while suggestions or the location load.
class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.keyword,
    required this.location,
    required this.locating,
  });

  final JobSuggestionsBloc keyword;
  final SearchLocationSuggestionsBloc location;
  final ValueNotifier<bool> locating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 3,
        child: BlocSelector<JobSuggestionsBloc, JobSuggestionsState, bool>(
          bloc: keyword,
          selector: (state) => state.isLoading,
          builder: (context, keywordLoading) =>
              BlocSelector<
                SearchLocationSuggestionsBloc,
                SearchLocationSuggestionsState,
                bool
              >(
                bloc: location,
                selector: (state) => state.isLoading,
                builder: (context, locationLoading) => ValueListenableBuilder(
                  valueListenable: locating,
                  builder: (context, isLocating, _) =>
                      keywordLoading || locationLoading || isLocating
                      ? const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          child: LinearProgressIndicator(minHeight: 3),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
        ),
      ),
    );
  }
}

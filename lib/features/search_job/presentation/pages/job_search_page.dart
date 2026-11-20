import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../shared/widgets/navy_page_header.dart';
import '../../../create_account/domain/entities/location_suggestion.dart';
import '../../../create_account/domain/enums/location_type.dart';
import '../../domain/entities/job_suggestion.dart';
import '../../domain/entities/search_query.dart';
import '../bloc/job_suggestions_bloc.dart';
import '../bloc/search_location_suggestions_bloc.dart';
import '../cubit/search_history_cubit.dart';
import '../widgets/location_permission_sheet.dart';
import '../widgets/job_suggestion_list.dart';
import '../widgets/location_suggestion_list.dart';
import '../models/search_filters.dart';
import '../widgets/search_fields_card.dart';
import '../widgets/search_filter_sheet.dart';
import 'job_search_results_page.dart';

/// Search screen: navy header with a filter button, the keyword and
/// location fields, and under them one list for the focused field:
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

  /// Ids and place parts from picked suggestions (and any filters the
  /// screen was opened with). Not UI state, so no notifier.
  late SearchQuery _filters = widget.initialQuery;

  /// Filter-sheet choices; a notifier so only the header badge rebuilds.
  late final _sheetFilters = ValueNotifier(
    SearchFilters.fromQuery(widget.initialQuery),
  );

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
    _sheetFilters.dispose();
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

  /// Plain keyword (popular or recent): clears any category/specialization.
  void _pickKeyword(String value) {
    _filters = _filters.withKeyword(value);
    _fillKeyword(value);
  }

  /// API suggestion: keeps whichever ids it has for the search.
  void _pickJobSuggestion(JobSuggestion s) {
    _filters = _filters.withKeyword(
      s.value,
      categoryId: s.categoryId,
      specializationId: s.specializationId,
    );
    _fillKeyword(s.value);
  }

  /// Fills the keyword and moves on to the location field.
  void _fillKeyword(String value) {
    _lastKeyword = value;
    _keywordController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _keywordSuggestions.add(const JobSuggestionsCleared());
    _goToLocation();
  }

  /// Switches to the location step: closes the keyword list, shows the
  /// location list and focuses the location field after the next frame.
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

  /// Plain location text: searched as `location`, no place parts.
  void _pickLocation(String value) {
    _filters = _filters.withLocation(value);
    _fillLocation(value);
  }

  /// API suggestion: sends its area/city/state, by type.
  void _pickLocationSuggestion(LocationSuggestion s, String label) {
    _filters = switch (s.type) {
      LocationType.area => _filters.withLocation(
        label,
        area: s.value,
        city: s.city,
        state: s.state,
      ),
      LocationType.state => _filters.withLocation(label, state: s.value),
      _ => _filters.withLocation(label, city: s.value, state: s.state),
    };
    _fillLocation(label);
  }

  /// Fills the location and runs the search.
  void _fillLocation(String value) {
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

  /// The field text plus the picked filters. If the user edited a field
  /// after picking, that field's ids/place parts no longer apply.
  SearchQuery _currentQuery() {
    final keyword = _keywordController.text.trim();
    final location = _locationController.text.trim();
    var q = _filters;
    if (keyword != q.keyword.trim()) q = q.withKeyword(keyword);
    if (location != q.location.trim()) q = q.withLocation(location);
    return q;
  }

  /// Runs [query] as given (a recent search keeps its own filters), or the
  /// fields plus the filter sheet's choices.
  void _search([SearchQuery? query]) {
    final q = query ?? _sheetFilters.value.applyTo(_currentQuery());
    if (q.isEmpty && _sheetFilters.value.isEmpty) {
      _keywordFocus.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    sl<SearchHistoryCubit>().add(q);
    Navigator.of(context).pushReplacement(JobSearchResultsPage.route(q));
  }

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final picked = await SearchFilterSheet.show(
      context,
      initial: _sheetFilters.value,
    );
    if (picked != null && mounted) _sheetFilters.value = picked;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Column(
          children: [
            NavyPageHeader(
              title: 'Search jobs',
              subtitle: 'Find your next opportunity',
              trailing: ValueListenableBuilder(
                valueListenable: _sheetFilters,
                builder: (context, filters, _) =>
                    _FilterButton(count: filters.count, onTap: _openFilters),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _activeField,
                builder: (context, active, _) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                          const SizedBox(height: 10),
                          SearchInputField(
                            controller: _locationController,
                            focusNode: _locationFocus,
                            active: active == SearchField.location,
                            icon: Icons.location_on_outlined,
                            hint: 'City, state or area',
                            action: TextInputAction.search,
                            onSubmitted: _search,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ProgressLine(
                      keyword: _keywordSuggestions,
                      location: _locationSuggestions,
                      locating: _locating,
                    ),
                    // Grey band between the fields and the list, matching
                    // the dashboard sections.
                    Container(height: 8, color: scheme.surfaceContainerHighest),
                    // Suggestions and recent searches for the focused field,
                    // in the page under the fields.
                    Expanded(
                      child: active == SearchField.keyword
                          ? JobSuggestionList(
                              text: _keywordController,
                              bloc: _keywordSuggestions,
                              onKeywordPicked: _pickKeyword,
                              onSuggestionPicked: _pickJobSuggestion,
                              onRecentSearch: _search,
                            )
                          : LocationSuggestionList(
                              text: _locationController,
                              bloc: _locationSuggestions,
                              locating: _locating,
                              onLocationPicked: _pickLocation,
                              onSuggestionPicked: _pickLocationSuggestion,
                              onUseCurrentLocation: _useCurrentLocation,
                            ),
                    ),
                  ],
                ),
              ),
            ),
            _SearchButtonBar(onPressed: _search),
          ],
        ),
      ),
    );
  }
}

/// Filter icon for the navy header, with a count of active filter groups.
class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: count == 0 ? 'Filters' : 'Filters, $count on',
      style: IconButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: count == 0
            ? AppColors.white.withValues(alpha: 0.10)
            : AppColors.primary,
        minimumSize: const Size.square(42),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: AppColors.white,
        textColor: AppColors.primary,
        child: const Icon(Icons.tune_rounded, size: 22),
      ),
    );
  }
}

/// "Search jobs" button pinned under the list.
class _SearchButtonBar extends StatelessWidget {
  const _SearchButtonBar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text('Search jobs'),
            ),
          ),
        ),
      ),
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

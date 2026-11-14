import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../domain/entities/job_suggestion.dart';
import '../../domain/entities/search_query.dart';
import '../../domain/usecases/get_job_suggestions_usecase.dart';
import '../bloc/job_suggestions_bloc.dart';
import '../cubit/search_history_cubit.dart';
import 'search_list_tiles.dart';

/// List under the keyword field.
///
/// - Keyword empty: recent searches (3, then "Show more") and popular
///   searches.
/// - Keyword typed: matching recent searches, then suggestions from
///   [JobSuggestionsBloc].
///
/// Picking a keyword calls [onKeywordPicked]; tapping a recent search calls
/// [onRecentSearch] to run it again.
class JobSuggestionList extends StatefulWidget {
  const JobSuggestionList({
    super.key,
    required this.text,
    required this.bloc,
    required this.onKeywordPicked,
    required this.onSuggestionPicked,
    required this.onRecentSearch,
  });

  /// The keyword field's text.
  final ValueListenable<TextEditingValue> text;
  final JobSuggestionsBloc bloc;

  /// Plain text picked (popular or recent keyword); no ids.
  final ValueChanged<String> onKeywordPicked;

  /// An API suggestion picked; carries its category/specialization ids.
  final ValueChanged<JobSuggestion> onSuggestionPicked;
  final ValueChanged<SearchQuery> onRecentSearch;

  @override
  State<JobSuggestionList> createState() => _JobSuggestionListState();
}

class _JobSuggestionListState extends State<JobSuggestionList> {
  static const _minChars = GetJobSuggestionsUseCase.minLength;

  /// Recent searches shown before "Show more".
  static const _historyPreview = 3;
  static const _popularSearches = [
    'staff nurse',
    'medical officer',
    'lab technician',
    'physiotherapist',
  ];

  final _showAllHistory = ValueNotifier(false);

  @override
  void dispose() {
    _showAllHistory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchHistoryCubit, List<SearchQuery>>(
      bloc: sl<SearchHistoryCubit>(),
      builder: (context, history) =>
          BlocBuilder<JobSuggestionsBloc, JobSuggestionsState>(
            bloc: widget.bloc,
            builder: (context, state) => ValueListenableBuilder(
              valueListenable: widget.text,
              builder: (context, value, _) {
                final text = value.text.trim();
                return ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: text.length >= _minChars
                      ? _typed(text, history, state)
                      : _empty(history),
                );
              },
            ),
          ),
    );
  }

  List<Widget> _empty(List<SearchQuery> history) {
    final cubit = sl<SearchHistoryCubit>();
    return [
      if (history.isNotEmpty) ...[
        const SearchSectionHeader(title: 'Recent searches'),
        ValueListenableBuilder(
          valueListenable: _showAllHistory,
          builder: (context, showAll, _) {
            final visible = showAll
                ? history
                : history.take(_historyPreview).toList();
            return Column(
              children: [
                for (final item in visible)
                  SearchRowTile(
                    icon: Icons.history_rounded,
                    title: item.keyword.isEmpty ? 'All jobs' : item.keyword,
                    subtitle: item.location.trim().isEmpty
                        ? 'Anywhere'
                        : 'in ${item.location.trim()}',
                    onRemove: () => cubit.remove(item),
                    onTap: () => widget.onRecentSearch(item),
                  ),
                if (history.length > _historyPreview)
                  _ShowMoreButton(
                    expanded: showAll,
                    onPressed: () => _showAllHistory.value = !showAll,
                  ),
              ],
            );
          },
        ),
      ],
      const SearchSectionHeader(title: 'Popular searches'),
      for (final term in _popularSearches)
        SearchRowTile(
          icon: Icons.search_rounded,
          title: term,
          onTap: () => widget.onKeywordPicked(term),
        ),
    ];
  }

  List<Widget> _typed(
    String text,
    List<SearchQuery> history,
    JobSuggestionsState state,
  ) {
    // API suggestions carry category/specialization ids, so when a recent
    // keyword has the same text, keep the suggestion and drop the recent row.
    final suggestions = state.suggestions;
    final suggested = suggestions.map((s) => s.value.toLowerCase()).toSet();
    final recent = _matchingRecent(
      text,
      history,
    ).where((k) => !suggested.contains(k.toLowerCase())).toList();

    return [
      const SizedBox(height: 4),
      for (final keyword in recent)
        SearchRowTile(
          icon: Icons.history_rounded,
          title: keyword,
          query: text,
          onTap: () => widget.onKeywordPicked(keyword),
        ),
      for (final s in suggestions)
        SearchRowTile(
          icon: Icons.search_rounded,
          title: s.value,
          subtitle: _hint(s),
          query: text,
          trailingText: _jobCount(s),
          onTap: () => widget.onSuggestionPicked(s),
        ),
      if (state.hasError)
        SearchListNote(
          "Couldn't load suggestions",
          actionLabel: 'Retry',
          onAction: () => widget.bloc.add(JobSuggestionsQueryChanged(text)),
        )
      else if (recent.isEmpty &&
          suggestions.isEmpty &&
          state.status == JobSuggestionsStatus.success)
        SearchListNote('No suggestions. Press Next to use "$text".'),
    ];
  }

  /// Up to 3 saved keywords containing [text], without duplicates.
  static List<String> _matchingRecent(String text, List<SearchQuery> history) {
    final needle = text.toLowerCase();
    final seen = <String>{};
    return [
      for (final item in history)
        if (item.keyword.trim() case final keyword
            when keyword.toLowerCase().contains(needle) &&
                seen.add(keyword.toLowerCase()))
          keyword,
    ].take(3).toList();
  }

  static String? _hint(JobSuggestion s) {
    final hint = s.hint?.trim();
    return hint == null || hint.isEmpty ? null : 'in $hint';
  }

  static String? _jobCount(JobSuggestion s) {
    final count = s.jobCount;
    if (count == null) return null;
    return '$count ${count == 1 ? 'job' : 'jobs'}';
  }
}

class _ShowMoreButton extends StatelessWidget {
  const _ShowMoreButton({required this.expanded, required this.onPressed});

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: TextButton.icon(
          onPressed: onPressed,
          iconAlignment: IconAlignment.end,
          icon: Icon(
            expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
          ),
          label: Text(expanded ? 'Show less' : 'Show more'),
        ),
      ),
    );
  }
}

part of 'languages_bloc.dart';

enum LanguagesStatus { initial, loading, success, failure }

/// Which change just finished, for the confirmation message.
enum LanguageChange { added, updated, removed }

class LanguagesState extends Equatable {
  final LanguagesStatus status;
  final List<Language> items;

  /// Set when loading fails.
  final Failure? failure;

  /// True while a new language is being added.
  final bool isAdding;

  /// Ids of languages whose update or delete request is still running.
  final Set<String> busyIds;

  /// Set for one state when an add, update or delete succeeds.
  final LanguageChange? change;

  /// Set for one state when an add, update or delete fails.
  final Failure? actionFailure;

  const LanguagesState({
    this.status = LanguagesStatus.initial,
    this.items = const [],
    this.failure,
    this.isAdding = false,
    this.busyIds = const {},
    this.change,
    this.actionFailure,
  });

  bool get isLoading =>
      status == LanguagesStatus.initial || status == LanguagesStatus.loading;

  bool isBusy(Language language) => busyIds.contains(language.id);

  List<String> get names => [for (final l in items) l.name];

  /// [failure], [change] and [actionFailure] are one-off values and reset
  /// unless passed again.
  LanguagesState copyWith({
    LanguagesStatus? status,
    List<Language>? items,
    Failure? failure,
    bool? isAdding,
    Set<String>? busyIds,
    LanguageChange? change,
    Failure? actionFailure,
  }) {
    return LanguagesState(
      status: status ?? this.status,
      items: items ?? this.items,
      failure: failure,
      isAdding: isAdding ?? this.isAdding,
      busyIds: busyIds ?? this.busyIds,
      change: change,
      actionFailure: actionFailure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    isAdding,
    busyIds,
    change,
    actionFailure,
  ];
}

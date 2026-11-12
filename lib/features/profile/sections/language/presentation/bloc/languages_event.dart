part of 'languages_bloc.dart';

sealed class LanguagesEvent extends Equatable {
  const LanguagesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads or reloads the list.
final class LanguagesRequested extends LanguagesEvent {
  const LanguagesRequested();
}

final class LanguageAdded extends LanguagesEvent {
  const LanguageAdded({required this.name, required this.proficiency});

  final String name;
  final LanguageProficiency proficiency;

  @override
  List<Object?> get props => [name, proficiency];
}

final class LanguageUpdated extends LanguagesEvent {
  const LanguageUpdated(this.language, this.proficiency);

  final Language language;
  final LanguageProficiency proficiency;

  @override
  List<Object?> get props => [language, proficiency];
}

final class LanguageDeleted extends LanguagesEvent {
  const LanguageDeleted(this.language);

  final Language language;

  @override
  List<Object?> get props => [language];
}

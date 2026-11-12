import 'package:equatable/equatable.dart';

/// How well the candidate speaks a language, from least to most.
/// [apiValue] is what the server sends and expects.
enum LanguageProficiency {
  basic('BASIC'),
  conversational('CONVERSATIONAL'),
  proficient('PROFICIENT'),
  fluent('FLUENT'),
  native('NATIVE');

  const LanguageProficiency(this.apiValue);

  final String apiValue;

  /// Unknown values fall back to [conversational] so the row still shows.
  static LanguageProficiency fromApi(String value) {
    final upper = value.toUpperCase();
    for (final p in values) {
      if (p.apiValue == upper) return p;
    }
    return conversational;
  }
}

/// A language on the signed-in candidate's profile.
class Language extends Equatable {
  final String id;
  final String name;
  final LanguageProficiency proficiency;
  final DateTime? createdAt;

  const Language({
    required this.id,
    required this.name,
    required this.proficiency,
    this.createdAt,
  });

  Language copyWith({LanguageProficiency? proficiency}) => Language(
    id: id,
    name: name,
    proficiency: proficiency ?? this.proficiency,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [id, name, proficiency, createdAt];
}

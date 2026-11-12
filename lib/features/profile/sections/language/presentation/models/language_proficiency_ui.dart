import '../../domain/entities/language.dart';

/// Text shown for each proficiency level.
extension LanguageProficiencyUi on LanguageProficiency {
  String get label => switch (this) {
    LanguageProficiency.basic => 'Basic',
    LanguageProficiency.conversational => 'Conversational',
    LanguageProficiency.proficient => 'Proficient',
    LanguageProficiency.fluent => 'Fluent',
    LanguageProficiency.native => 'Native',
  };

  String get description => switch (this) {
    LanguageProficiency.basic => 'Simple words and phrases',
    LanguageProficiency.conversational =>
      'Everyday talk with patients and staff',
    LanguageProficiency.proficient => 'Work confidently in most situations',
    LanguageProficiency.fluent => 'Clinical conversations with ease',
    LanguageProficiency.native => 'First language',
  };
}

/// Groups used for suggestion tabs and search result labels.
enum SkillCategory {
  clinical('Clinical'),
  certifications('Certifications'),
  specialty('Specialty'),
  softSkills('Soft skills');

  const SkillCategory(this.label);

  final String label;
}

/// A skill the sheet can suggest or find in search.
class SkillOption {
  const SkillOption(this.name, this.category);

  final String name;
  final SkillCategory category;
}

/// Skills offered in the edit sheet. There's no suggestions API yet, so this
/// is a fixed healthcare catalogue used for search and one-tap suggestions.
abstract final class SkillSuggestions {
  /// Most users can stay under this. It keeps the profile easy to scan.
  static const maxSkills = 15;

  /// Longest custom skill a user can type.
  static const maxLength = 40;

  /// From this many skills on, the profile counts as strong.
  static const goodCount = 6;

  /// Tabs shown under "Suggested", in order.
  static const suggestedTabs = [
    SkillCategory.clinical,
    SkillCategory.certifications,
    SkillCategory.softSkills,
  ];

  /// Searched as the user types, and the source of each tab's suggestions.
  static const catalogue = [
    // Clinical
    SkillOption('Cardiac monitoring', SkillCategory.clinical),
    SkillOption('Cardiopulmonary resuscitation', SkillCategory.clinical),
    SkillOption('Catheterization', SkillCategory.clinical),
    SkillOption('Critical care', SkillCategory.clinical),
    SkillOption('Dialysis', SkillCategory.clinical),
    SkillOption('ICU care', SkillCategory.clinical),
    SkillOption('Infection control', SkillCategory.clinical),
    SkillOption('IV therapy', SkillCategory.clinical),
    SkillOption('Medication administration', SkillCategory.clinical),
    SkillOption('Patient assessment', SkillCategory.clinical),
    SkillOption('Phlebotomy', SkillCategory.clinical),
    SkillOption('Post-operative care', SkillCategory.clinical),
    SkillOption('Tracheostomy care', SkillCategory.clinical),
    SkillOption('Triage', SkillCategory.clinical),
    SkillOption('Ventilator care', SkillCategory.clinical),
    SkillOption('Vital signs monitoring', SkillCategory.clinical),
    SkillOption('Wound care', SkillCategory.clinical),
    // Certifications
    SkillOption('ACLS', SkillCategory.certifications),
    SkillOption('BLS', SkillCategory.certifications),
    SkillOption('BLS / ACLS', SkillCategory.certifications),
    SkillOption('NRP', SkillCategory.certifications),
    SkillOption('PALS', SkillCategory.certifications),
    SkillOption('TNCC', SkillCategory.certifications),
    // Specialty
    SkillOption('Cardiology nursing', SkillCategory.specialty),
    SkillOption('Emergency care', SkillCategory.specialty),
    SkillOption('Neonatal care', SkillCategory.specialty),
    SkillOption('Oncology nursing', SkillCategory.specialty),
    SkillOption('Operating theatre', SkillCategory.specialty),
    SkillOption('Pediatric care', SkillCategory.specialty),
    SkillOption('Telemetry', SkillCategory.specialty),
    // Soft skills
    SkillOption('Clinical documentation', SkillCategory.softSkills),
    SkillOption('Discharge planning', SkillCategory.softSkills),
    SkillOption('Electronic medical records (EMR)', SkillCategory.softSkills),
    SkillOption('Patient education', SkillCategory.softSkills),
    SkillOption('Team leadership', SkillCategory.softSkills),
    SkillOption('Time management', SkillCategory.softSkills),
  ];

  static List<SkillOption> inCategory(SkillCategory category) => [
    for (final option in catalogue)
      if (option.category == category) option,
  ];

  /// Category of a known skill, or null for a custom one.
  static SkillCategory? categoryOf(String name) {
    final lower = name.toLowerCase();
    for (final option in catalogue) {
      if (option.name.toLowerCase() == lower) return option.category;
    }
    return null;
  }
}

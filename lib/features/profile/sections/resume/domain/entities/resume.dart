import 'package:equatable/equatable.dart';

/// A candidate's CV. Built CVs have a [templateKey] and [content]; uploaded
/// ones have neither. [generatedFileId] is the PDF, null until it exists.
class Resume extends Equatable {
  final String id;
  final String candidateId;
  final String title;
  final String? templateKey;
  final ResumeContent content;
  final String? generatedFileId;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Resume({
    required this.id,
    required this.candidateId,
    required this.title,
    this.templateKey,
    this.content = const ResumeContent(),
    this.generatedFileId,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasFile => generatedFileId != null && generatedFileId!.isNotEmpty;

  /// Uploaded files come without a template.
  bool get isUploaded => templateKey == null || templateKey!.trim().isEmpty;

  Resume copyWith({bool? isDefault}) {
    return Resume(
      id: id,
      candidateId: candidateId,
      title: title,
      templateKey: templateKey,
      content: content,
      generatedFileId: generatedFileId,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    candidateId,
    title,
    templateKey,
    content,
    generatedFileId,
    isDefault,
    createdAt,
    updatedAt,
  ];
}

/// The `contentJson` of a built CV. Empty for uploaded CVs.
class ResumeContent extends Equatable {
  final String fullName;
  final String headline;
  final String email;
  final String phone;
  final String location;
  final String linkedinUrl;
  final String summary;
  final bool showPhoto;
  final List<String> skills;
  final List<ResumeLanguage> languages;

  /// Item shapes for these aren't fixed yet, so they're kept as raw maps.
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;
  final List<Map<String, dynamic>> certifications;
  final List<Map<String, dynamic>> achievements;

  /// Section keys in display order, e.g. `summary`, `experience`.
  final List<String> sectionOrder;

  const ResumeContent({
    this.fullName = '',
    this.headline = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedinUrl = '',
    this.summary = '',
    this.showPhoto = false,
    this.skills = const [],
    this.languages = const [],
    this.experience = const [],
    this.education = const [],
    this.certifications = const [],
    this.achievements = const [],
    this.sectionOrder = const [],
  });

  @override
  List<Object?> get props => [
    fullName,
    headline,
    email,
    phone,
    location,
    linkedinUrl,
    summary,
    showPhoto,
    skills,
    languages,
    experience,
    education,
    certifications,
    achievements,
    sectionOrder,
  ];
}

class ResumeLanguage extends Equatable {
  final String language;

  /// Raw API value, e.g. `NATIVE`, `PROFICIENT`, `BASIC`.
  final String proficiency;

  const ResumeLanguage({required this.language, required this.proficiency});

  @override
  List<Object?> get props => [language, proficiency];
}

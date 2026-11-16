import '../../../../../../core/utils/json_parser.dart';
import '../../domain/entities/resume.dart';

class ResumeModel extends Resume {
  const ResumeModel({
    required super.id,
    required super.candidateId,
    required super.title,
    super.templateKey,
    super.content,
    super.generatedFileId,
    super.isDefault,
    super.createdAt,
    super.updatedAt,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: JsonParser.string(json['id']),
      candidateId: JsonParser.string(json['candidateId']),
      title: JsonParser.string(json['title']).trim(),
      templateKey: JsonParser.nullableString(json['templateKey']),
      content: ResumeContentModel.fromJson(JsonParser.map(json['contentJson'])),
      generatedFileId: JsonParser.nullableString(json['generatedFileId']),
      isDefault: JsonParser.boolean(json['isDefault']),
      createdAt: JsonParser.dateTime(json['createdAt']),
      updatedAt: JsonParser.dateTime(json['updatedAt']),
    );
  }

  /// Reads `{data: [...]}`.
  static List<ResumeModel> listFromJson(Object? json) {
    final root = JsonParser.map(json);
    return [
      for (final item in JsonParser.list(root['data']))
        if (item is Map<String, dynamic>) ResumeModel.fromJson(item),
    ];
  }
}

class ResumeContentModel extends ResumeContent {
  const ResumeContentModel({
    super.fullName,
    super.headline,
    super.email,
    super.phone,
    super.location,
    super.linkedinUrl,
    super.summary,
    super.showPhoto,
    super.skills,
    super.languages,
    super.experience,
    super.education,
    super.certifications,
    super.achievements,
    super.sectionOrder,
  });

  factory ResumeContentModel.fromJson(Map<String, dynamic> json) {
    return ResumeContentModel(
      fullName: JsonParser.string(json['fullName']).trim(),
      headline: JsonParser.string(json['headline']).trim(),
      email: JsonParser.string(json['email']).trim(),
      phone: JsonParser.string(json['phone']).trim(),
      location: JsonParser.string(json['location']).trim(),
      linkedinUrl: JsonParser.string(json['linkedinUrl']).trim(),
      summary: JsonParser.string(json['summary']).trim(),
      showPhoto: JsonParser.boolean(json['showPhoto']),
      skills: _strings(json['skills']),
      languages: [
        for (final item in JsonParser.list(json['languages']))
          if (item is Map<String, dynamic>)
            ResumeLanguage(
              language: JsonParser.string(item['language']),
              proficiency: JsonParser.string(item['proficiency']),
            ),
      ],
      experience: _maps(json['experience']),
      education: _maps(json['education']),
      certifications: _maps(json['certifications']),
      achievements: _maps(json['achievements']),
      sectionOrder: _strings(json['sectionOrder']),
    );
  }

  static List<String> _strings(Object? value) => [
    for (final item in JsonParser.list(value))
      if (item != null && item.toString().trim().isNotEmpty)
        item.toString().trim(),
  ];

  static List<Map<String, dynamic>> _maps(Object? value) => [
    for (final item in JsonParser.list(value))
      if (item is Map<String, dynamic>) item,
  ];
}

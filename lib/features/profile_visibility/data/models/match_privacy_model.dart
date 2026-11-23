import '../../../../core/utils/json_parser.dart';
import '../../domain/entities/match_privacy.dart';

abstract final class MatchPrivacyModel {
  /// Parses `{ "data": { matchDiscoverable, shareContactOnReveal, ... } }`.
  static MatchPrivacy fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root.containsKey('data') ? JsonParser.map(root['data']) : root;
    final plan = JsonParser.map(data['plan']);
    return MatchPrivacy(
      matchDiscoverable: JsonParser.boolean(data['matchDiscoverable']),
      shareContactOnReveal: JsonParser.boolean(data['shareContactOnReveal']),
      updatedAt: JsonParser.dateTime(data['updatedAt']),
      planProfileVisibility: JsonParser.boolean(plan['profileVisibility']),
      planResumeVisibility: JsonParser.boolean(plan['resumeVisibility']),
    );
  }

  static Map<String, dynamic> toUpdateJson({
    required bool matchDiscoverable,
    required bool shareContactOnReveal,
  }) => {
    'matchDiscoverable': matchDiscoverable,
    'shareContactOnReveal': shareContactOnReveal,
  };
}

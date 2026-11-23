import 'package:equatable/equatable.dart';

/// The candidate's match-privacy settings (`GET candidates/me/match-privacy`).
class MatchPrivacy extends Equatable {
  const MatchPrivacy({
    required this.matchDiscoverable,
    required this.shareContactOnReveal,
    this.updatedAt,
    this.planProfileVisibility = false,
    this.planResumeVisibility = false,
  });

  /// Employers can find the profile in candidate matching.
  final bool matchDiscoverable;

  /// Contact details are shared when an employer reveals the profile.
  final bool shareContactOnReveal;
  final DateTime? updatedAt;

  /// Plan flags echoed back by the server (`plan` object).
  final bool planProfileVisibility;
  final bool planResumeVisibility;

  MatchPrivacy copyWith({bool? matchDiscoverable, bool? shareContactOnReveal}) {
    return MatchPrivacy(
      matchDiscoverable: matchDiscoverable ?? this.matchDiscoverable,
      shareContactOnReveal: shareContactOnReveal ?? this.shareContactOnReveal,
      updatedAt: updatedAt,
      planProfileVisibility: planProfileVisibility,
      planResumeVisibility: planResumeVisibility,
    );
  }

  @override
  List<Object?> get props => [
    matchDiscoverable,
    shareContactOnReveal,
    updatedAt,
    planProfileVisibility,
    planResumeVisibility,
  ];
}

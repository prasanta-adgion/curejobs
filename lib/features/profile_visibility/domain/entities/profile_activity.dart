import 'package:equatable/equatable.dart';

/// One employer interaction with the profile, e.g. `REVEALED`.
class ProfileActivityItem extends Equatable {
  const ProfileActivityItem({
    required this.id,
    required this.kind,
    required this.organizationName,
    this.jobId,
    this.jobTitle,
    this.at,
  });

  final String id;
  final String kind;
  final String organizationName;
  final String? jobId;
  final String? jobTitle;
  final DateTime? at;

  bool get isRevealed => kind == 'REVEALED';

  @override
  List<Object?> get props => [id, kind, organizationName, jobId, jobTitle, at];
}

/// `GET candidates/me/profile-activity`.
class ProfileActivity extends Equatable {
  const ProfileActivity({
    this.items = const [],
    this.total = 0,
    this.lockedCount = 0,
    this.isPro = false,
  });

  final List<ProfileActivityItem> items;
  final int total;

  /// Entries hidden because the plan doesn't include them.
  final int lockedCount;
  final bool isPro;

  @override
  List<Object?> get props => [items, total, lockedCount, isPro];
}

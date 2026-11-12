import 'package:equatable/equatable.dart';

/// A skill on the signed-in candidate's profile.
class Skill extends Equatable {
  final String id;
  final String name;

  /// Lower-case form the API uses for matching and de-duplication.
  final String normalizedName;
  final DateTime? createdAt;

  const Skill({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, normalizedName, createdAt];
}

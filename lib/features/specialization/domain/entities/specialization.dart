import 'package:equatable/equatable.dart';

/// A specialty within a job category.
class Specialization extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int sortOrder;

  const Specialization({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, slug, description, sortOrder];
}

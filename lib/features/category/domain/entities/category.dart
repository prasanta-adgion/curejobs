import 'package:equatable/equatable.dart';

/// A healthcare job category, such as Nursing or Pharmacy.
class Category extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.sortOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, slug, description, sortOrder];
}

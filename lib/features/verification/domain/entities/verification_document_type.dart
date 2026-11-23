import 'package:equatable/equatable.dart';

/// A document the user can upload for verification, from the
/// document-types API (`{ id, code, name, isRequired }`).
class VerificationDocumentType extends Equatable {
  const VerificationDocumentType({
    required this.id,
    required this.code,
    required this.name,
    required this.isRequired,
  });

  final String id;
  final String code;
  final String name;
  final bool isRequired;

  @override
  List<Object?> get props => [id, code, name, isRequired];
}

/// Where the progress tracker is.
enum VerificationStep { plan, documents, review, badge }

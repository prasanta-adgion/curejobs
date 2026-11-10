import 'package:equatable/equatable.dart';

/// The account the server created, and what the user must do next.
class RegistrationResult extends Equatable {
  final String userId;
  final String email;
  final String role;
  final String status;
  final bool emailVerified;
  final bool emailVerificationRequired;

  const RegistrationResult({
    required this.userId,
    required this.email,
    required this.role,
    required this.status,
    required this.emailVerified,
    required this.emailVerificationRequired,
  });

  @override
  List<Object?> get props => [
    userId,
    email,
    role,
    status,
    emailVerified,
    emailVerificationRequired,
  ];
}

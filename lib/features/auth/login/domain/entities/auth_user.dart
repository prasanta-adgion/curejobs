import 'package:equatable/equatable.dart';

/// The signed-in user, as the rest of the app sees it.
class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? name;

  const AuthUser({required this.id, required this.email, this.name});

  @override
  List<Object?> get props => [id, email, name];
}

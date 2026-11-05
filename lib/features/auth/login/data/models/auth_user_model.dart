import '../../../../../core/utils/json_parser.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({required super.id, required super.email, super.name});

  /// Accepts `{data: {user: {...}}}`, `{user: {...}}` or a bare user object.
  factory AuthUserModel.fromJson(Object? json) {
    final root = json as Map<String, dynamic>;
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    final user = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : data;

    return AuthUserModel(
      id: JsonParser.string(user['id']),
      email: user['email'] as String,
      name: JsonParser.nullableString(user['name']),
    );
  }
}

import '../../../../../core/utils/json_parser.dart';
import '../../domain/entities/registration_result.dart';

class RegistrationResultModel extends RegistrationResult {
  const RegistrationResultModel({
    required super.userId,
    required super.email,
    required super.role,
    required super.status,
    required super.emailVerified,
    required super.emailVerificationRequired,
  });

  /// Parses `{data: {user: {...}, emailVerificationRequired: bool}}`.
  factory RegistrationResultModel.fromJson(Object? json) {
    final root = JsonParser.map(json);
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : root;
    final user = JsonParser.map(data['user']);

    return RegistrationResultModel(
      userId: JsonParser.string(user['id']),
      email: user['email'] as String,
      role: JsonParser.string(user['role']),
      status: JsonParser.string(user['status']),
      emailVerified: JsonParser.boolean(user['emailVerified']),
      emailVerificationRequired: JsonParser.boolean(
        data['emailVerificationRequired'],
        fallback: true,
      ),
    );
  }
}

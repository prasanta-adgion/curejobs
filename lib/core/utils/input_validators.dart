/// App-wide form field checks. Each returns an error message or null, so they
/// plug straight into `TextFormField.validator`.
abstract final class InputValidators {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _digit = RegExp(r'\d');
  static final _lower = RegExp(r'[a-z]');
  static final _upper = RegExp(r'[A-Z]');
  static final _special = RegExp(r'[^A-Za-z0-9\s]');

  static const minPasswordLength = 8;

  /// Hint shown under a new-password field.
  static const strongPasswordHint =
      'At least $minPasswordLength characters with uppercase, lowercase, '
      'a number and a symbol';

  static String? required(String? value, {String fieldName = 'this field'}) {
    if (value == null || value.trim().isEmpty) return 'Enter $fieldName';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  /// Sign-in: only checks the field is filled.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  /// Sign-up and password change: enforces a strong password.
  static String? strongPassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Create a password';
    if (password.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    if (!password.contains(_upper)) return 'Include an uppercase letter';
    if (!password.contains(_lower)) return 'Include a lowercase letter';
    if (!password.contains(_digit)) return 'Include a number';
    if (!password.contains(_special)) return 'Include a symbol, like ! or @';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Re-enter your password';
    if (value != password) return "Passwords don't match";
    return null;
  }

  /// Score from 0 (empty) to 4 (meets every [strongPassword] rule).
  static int passwordStrength(String password) {
    if (password.isEmpty) return 0;
    var score = 0;
    if (password.length >= minPasswordLength) score++;
    if (password.contains(_digit)) score++;
    if (password.contains(_lower) && password.contains(_upper)) score++;
    if (password.contains(_special)) score++;
    return score == 0 ? 1 : score;
  }
}

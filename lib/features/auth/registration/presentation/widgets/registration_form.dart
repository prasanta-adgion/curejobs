import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/utils/input_validators.dart';

/// Email, password and confirm password form. Validates locally, then calls
/// [onSubmit]. UI only: no networking yet.
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key, this.onSubmit, this.isLoading = false});

  final void Function(String email, String password)? onSubmit;
  final bool isLoading;

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit?.call(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = widget.isLoading;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Label('Email address'),
            TextFormField(
              controller: _email,
              enabled: !loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: InputValidators.email,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            const _Label('Password'),
            TextFormField(
              controller: _password,
              focusNode: _passwordFocus,
              enabled: !loading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: 'Enter password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: _VisibilityToggle(
                  obscured: _obscurePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: InputValidators.strongPassword,
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
            ),
            const SizedBox(height: 8),
            _PasswordStrength(password: _password.text),
            const SizedBox(height: 16),
            const _Label('Confirm password'),
            TextFormField(
              controller: _confirm,
              focusNode: _confirmFocus,
              enabled: !loading,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                hintText: 'Re-enter password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: _VisibilityToggle(
                  obscured: _obscureConfirm,
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              validator: (value) =>
                  InputValidators.confirmPassword(value, _password.text),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.primary,
                        ),
                      )
                    : const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: obscured ? 'Show password' : 'Hide password',
      icon: Icon(
        obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      ),
      onPressed: onPressed,
    );
  }
}

/// Four-segment strength bar with a short label. Shows a hint while empty.
class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final score = InputValidators.passwordStrength(password);

    if (score == 0) {
      return Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              InputValidators.strongPasswordHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      );
    }

    final (label, color) = switch (score) {
      1 => ('Weak password', AppColors.error),
      2 => ('Fair password', AppColors.warning),
      3 => ('Good password', AppColors.warning),
      _ => ('Strong password', AppColors.success),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < score ? color : scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection_container.dart';
import '../../domain/entities/registration_result.dart';
import '../bloc/registration_bloc.dart';
import '../widgets/registration_form.dart';
import '../widgets/registration_header.dart';

/// Email and password sign-up screen.
///
/// On success it calls [onRegistered]; without one it confirms with a
/// snackbar and returns to the previous (sign-in) screen.
class RegistrationPage extends StatelessWidget {
  const RegistrationPage({
    super.key,
    this.onRegistered,
    this.onBack,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final ValueChanged<RegistrationResult>? onRegistered;
  final VoidCallback? onBack;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  void _handleSuccess(BuildContext context, RegistrationResult result) {
    if (onRegistered != null) {
      onRegistered!(result);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.emailVerificationRequired
              ? 'Account created. Check ${result.email} to verify your email.'
              : 'Account created. You can now sign in.',
        ),
      ),
    );
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegistrationBloc>(),
      child: BlocListener<RegistrationBloc, RegistrationState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status &&
            curr.status == RegistrationStatus.success,
        listener: (context, state) => _handleSuccess(context, state.result!),
        child: _RegistrationView(
          onBack: onBack,
          onTermsTap: onTermsTap,
          onPrivacyTap: onPrivacyTap,
        ),
      ),
    );
  }
}

class _RegistrationView extends StatelessWidget {
  const _RegistrationView({this.onBack, this.onTermsTap, this.onPrivacyTap});

  final VoidCallback? onBack;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              RegistrationHeader(onBack: onBack),
              Transform.translate(
                offset: const Offset(0, -48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: scheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const RegistrationForm(),
                              const SizedBox(height: 16),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                    ),
                                    child: const Text('Sign in'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                children: [
                                  Text(
                                    'By continuing, you agree to our ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.outline,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: onTermsTap,
                                    child: Text(
                                      'Terms of service',
                                      style: linkStyle,
                                    ),
                                  ),
                                  Text(
                                    ' and ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.outline,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: onPrivacyTap,
                                    child: Text(
                                      'Privacy policy',
                                      style: linkStyle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

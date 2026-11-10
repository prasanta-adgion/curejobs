import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_snackbar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection_container.dart';
import '../../../common/presentation/widgets/auth_step_header.dart';
import '../../../otp_verification/presentation/pages/otp_verification_page.dart';
import '../../domain/entities/registration_result.dart';
import '../bloc/registration_bloc.dart';
import '../widgets/registration_form.dart';

/// Email and password sign-up screen.
///
/// On success it calls [onRegistered]; without one it opens the email
/// verification screen (step 2), or returns to sign-in when the server
/// doesn't need verification.
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

  void _handleSuccess(
    BuildContext context,
    RegistrationResult result,
    String password,
  ) {
    if (onRegistered != null) {
      onRegistered!(result);
      return;
    }

    if (result.emailVerificationRequired) {
      // Pushed on top, so "Change email" can come back to this form.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationPage(email: result.email, password: password),
        ),
      );
      return;
    }

    AppSnackbar.success(
      title: 'Account created',
      message: 'You can now sign in.',
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
        listener: (context, state) =>
            _handleSuccess(context, state.result!, state.password!),
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

  /// How far the card overlaps the purple header.
  static const double _overlap = 48;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.outline,
    );
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              AuthStepHeader(
                onBack: onBack,
                currentStep: 1,
                totalSteps: 2,
                bottomPadding: _overlap + 16,
              ),
              Transform.translate(
                offset: const Offset(0, -_overlap),
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
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Create your account',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find nursing and healthcare jobs near you.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const RegistrationForm(),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.maybePop(context),
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
                                alignment: WrapAlignment.center,
                                children: [
                                  Text(
                                    'By continuing, you agree to our ',
                                    style: mutedStyle,
                                  ),
                                  GestureDetector(
                                    onTap: onTermsTap,
                                    child: Text(
                                      'Terms of service',
                                      style: linkStyle,
                                    ),
                                  ),
                                  Text(' and ', style: mutedStyle),
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

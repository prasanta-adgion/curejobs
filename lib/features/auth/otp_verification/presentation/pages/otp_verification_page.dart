import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection_container.dart';
import '../../../common/presentation/widgets/auth_step_header.dart';
import '../../../../create_account/presentation/pages/create_account_page.dart';
import '../bloc/otp_verification_bloc.dart';
import '../widgets/otp_code_input.dart';
import '../widgets/otp_resend_row.dart';

/// Step 2 of sign-up: enter the 6-digit code emailed to [email].
///
/// A correct code verifies the email, then signs in with [password] (the
/// session is stored just like after login) and replaces every auth screen
/// with profile setup ([CreateAccountPage]), so Back can't return to sign-up.
///
/// If that automatic sign-in fails, the user is sent to the login screen.
class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.password,
  });

  final String email;

  /// The password just used to register; only kept for the sign-in.
  final String password;

  void _handleVerified(BuildContext context, OtpVerificationState state) {
    final navigator = Navigator.of(context);

    if (state.isSignedIn) {
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const CreateAccountPage()),
        (_) => false,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verified. Sign in to continue.')),
    );
    navigator.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<OtpVerificationBloc>(param1: email, param2: password)
            ..add(const OtpStarted()),
      child: MultiBlocListener(
        listeners: [
          BlocListener<OtpVerificationBloc, OtpVerificationState>(
            listenWhen: (prev, curr) =>
                prev.status != curr.status && curr.status == OtpStatus.verified,
            listener: _handleVerified,
          ),
          BlocListener<OtpVerificationBloc, OtpVerificationState>(
            listenWhen: (prev, curr) => curr.codesSent > prev.codesSent,
            listener: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('New code sent to ${state.email}')),
                );
            },
          ),
        ],
        child: const _OtpVerificationView(),
      ),
    );
  }
}

class _OtpVerificationView extends StatefulWidget {
  const _OtpVerificationView();

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  /// How far the card overlaps the purple header.
  static const double _overlap = 48;

  final _code = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<OtpVerificationBloc>().add(const OtpSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocListener<OtpVerificationBloc, OtpVerificationState>(
      // A resend empties the code in state; mirror that in the boxes.
      listenWhen: (prev, curr) => curr.code.isEmpty && _code.text.isNotEmpty,
      listener: (_, _) {
        _code.clear();
        _focus.requestFocus();
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const AuthStepHeader(
                  currentStep: 2,
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
                            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                            child:
                                BlocBuilder<
                                  OtpVerificationBloc,
                                  OtpVerificationState
                                >(
                                  builder: (context, state) =>
                                      _buildContent(context, state),
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, OtpVerificationState state) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bloc = context.read<OtpVerificationBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 30,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We sent a ${OtpVerificationBloc.codeLength}-digit code to',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              state.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              // Registration is underneath with the form still filled in.
              onPressed: state.isVerifying
                  ? null
                  : () => Navigator.maybePop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Change'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        OtpCodeInput(
          controller: _code,
          focusNode: _focus,
          length: OtpVerificationBloc.codeLength,
          enabled: !state.isVerifying,
          errorText: state.errorMessage,
          onChanged: (code) => bloc.add(OtpCodeChanged(code)),
          // Verify as soon as the last digit is in.
          onCompleted: (code) {
            bloc.add(OtpCodeChanged(code));
            _submit();
          },
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: FilledButton(
            onPressed: state.canSubmit ? _submit : null,
            child: state.isVerifying
                ? SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: scheme.primary,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Verify email'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        OtpResendRow(
          secondsLeft: state.resendIn,
          isResending: state.isResending,
          onResend: state.canResend
              ? () => bloc.add(const OtpResendRequested())
              : null,
        ),
        const SizedBox(height: 12),
        _TipBox(
          text:
              "Can't find it? Check your spam or promotions folder. "
              'The code is only valid for a short time.',
        ),
      ],
    );
  }
}

class _TipBox extends StatelessWidget {
  const _TipBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di/injection_container.dart';
import '../../domain/entities/auth_user.dart';
import '../bloc/login_bloc.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

/// Email and password sign-in screen. Navigation is left to the caller.
class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
    required this.onLoggedIn,
    this.onForgotPassword,
    this.onCreateAccount,
  });

  final ValueChanged<AuthUser> onLoggedIn;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginBloc>(),
      child: BlocListener<LoginBloc, LoginState>(
        listenWhen: (prev, curr) => curr.status == LoginStatus.success,
        listener: (context, state) => onLoggedIn(state.user!),
        child: _LoginView(
          onForgotPassword: onForgotPassword,
          onCreateAccount: onCreateAccount,
        ),
      ),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({this.onForgotPassword, this.onCreateAccount});

  final VoidCallback? onForgotPassword;
  final VoidCallback? onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const LoginHeader(),
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
                          child: LoginForm(onForgotPassword: onForgotPassword),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'New to CureJobs?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: onCreateAccount,
                    child: const Text('Create a free account'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 14, color: scheme.outline),
                    const SizedBox(width: 4),
                    Text(
                      'Your data is secure and private',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/logout_bloc.dart';
import 'profile_section.dart';

/// Last block of the profile: a red "Log out" button that asks for
/// confirmation, then sends [LogoutRequested] to [LogoutBloc].
class LogoutSection extends StatelessWidget {
  const LogoutSection({super.key});

  Future<void> _confirm(BuildContext context) async {
    final bloc = context.read<LogoutBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const _LogoutDialog(),
    );
    if (confirmed ?? false) bloc.add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ProfileSection(
      title: 'Account',
      child: BlocBuilder<LogoutBloc, LogoutState>(
        builder: (context, state) {
          // Stays busy after success until the screen is replaced.
          final busy = state.isLoading || state.status == LogoutStatus.success;

          return SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _confirm(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: busy
                  ? SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.error,
                      ),
                    )
                  : const Icon(Icons.logout_rounded, size: 20),
              label: Text(busy ? 'Logging out…' : 'Log out'),
            ),
          );
        },
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.logout_rounded, color: scheme.error),
      ),
      title: const Text('Log out of CureJobs?'),
      content: Text(
        "You'll need to sign in again to apply for jobs and see your "
        'applications.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

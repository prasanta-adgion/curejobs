import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../job_alerts/presentation/pages/job_alerts_page.dart';
import '../../../subscription_packages/presentation/bloc/current_plan_bloc.dart';
import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart';
import '../../domain/entities/candidate.dart';
import '../../shared/widgets/profile_section.dart';
import '../bloc/candidate_profile_bloc.dart';

/// "Quick access": four cards for Verification, Profile visibility, Job
/// alerts and Billing and plans. Each shows its status so the user sees
/// where they stand without opening anything.
class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key, this.showDivider = true});

  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CurrentPlanBloc>()..add(const CurrentPlanRequested()),
      child: ProfileSection(
        title: 'Quick access',
        showDivider: showDivider,
        child: const _Grid(),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid();

  void _comingSoon(BuildContext context, String name) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$name is coming soon')));

  Future<void> _openPlans(BuildContext context) async {
    final plan = context.read<CurrentPlanBloc>();
    await Navigator.of(context).push(SubscriptionPackagesPage.route());
    // The plan may have changed.
    plan.add(const CurrentPlanRequested());
  }

  @override
  Widget build(BuildContext context) {
    final tones = _Tones.of(context);

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child:
                    BlocSelector<
                      CandidateProfileBloc,
                      CandidateProfileState,
                      CandidateVerification?
                    >(
                      selector: (state) => state.candidate?.verification,
                      builder: (context, verification) => _QuickCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Verification',
                        subtitle: 'Your documents',
                        tone: tones.success,
                        status: _verificationStatus(verification, tones),
                        onTap: () => _comingSoon(context, 'Verification'),
                      ),
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.visibility_outlined,
                  title: 'Profile visibility',
                  subtitle: 'Who can find you',
                  tone: tones.accent,
                  onTap: () => _comingSoon(context, 'Profile visibility'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.notifications_none_rounded,
                  title: 'Job alerts',
                  subtitle: 'New jobs for you',
                  tone: tones.violet,
                  onTap: () =>
                      Navigator.of(context).push(JobAlertsPage.route()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlocBuilder<CurrentPlanBloc, CurrentPlanState>(
                  builder: (context, state) {
                    final s = state.subscription;
                    final end = s?.expiresAt;
                    return _QuickCard(
                      icon: Icons.credit_card_rounded,
                      title: 'Billing and plans',
                      subtitle: s == null || s.isFree || end == null
                          ? 'Your subscription'
                          : s.isEndingSoon
                          ? 'Ends in ${s.daysLeft()} days'
                          : 'Renews ${PackageFormat.date(end)}',
                      tone: tones.warning,
                      status: s == null
                          ? null
                          : _Status(
                              '${PackageFormat.shortName(s.package.name)} plan',
                              tones.warning,
                            ),
                      onTap: () => _openPlans(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static _Status? _verificationStatus(CandidateVerification? v, _Tones tones) {
    if (v == null) return null;
    if (v.isVerifiedAt(DateTime.now()))
      return _Status('Verified', tones.success);
    return switch (v.documentStatus) {
      DocumentStatus.pending => _Status('In review', tones.warning),
      DocumentStatus.rejected => _Status('Action needed', tones.danger),
      DocumentStatus.approved => _Status('Approved', tones.success),
      DocumentStatus.notSubmitted => _Status('Not verified', tones.neutral),
    };
  }
}

class _Status {
  const _Status(this.label, this.tone);

  final String label;
  final _Tone tone;
}

/// A soft background with a matching strong colour for icons and text.
class _Tone {
  const _Tone(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

class _Tones {
  _Tones.of(BuildContext context)
    : _dark = Theme.of(context).brightness == Brightness.dark,
      _scheme = Theme.of(context).colorScheme;

  final bool _dark;
  final ColorScheme _scheme;

  _Tone _pick(MaterialColor c) => _dark
      ? _Tone(c.shade900.withValues(alpha: 0.45), c.shade200)
      : _Tone(c.shade50, c.shade800);

  _Tone get success => _pick(Colors.green);
  _Tone get warning => _pick(Colors.amber);
  _Tone get danger => _pick(Colors.red);
  _Tone get violet => _pick(Colors.deepPurple);
  _Tone get accent =>
      _Tone(_scheme.primaryContainer, _scheme.onPrimaryContainer);
  _Tone get neutral =>
      _Tone(_scheme.surfaceContainerHighest, _scheme.onSurfaceVariant);
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.onTap,
    this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _Tone tone;
  final _Status? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = this.status;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileIconTile(
                icon: icon,
                size: 36,
                background: tone.background,
                color: tone.foreground,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (status != null) ...[
                const Spacer(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: status.tone.background,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: status.tone.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

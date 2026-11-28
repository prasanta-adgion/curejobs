import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../subscription_packages/domain/entities/current_subscription.dart';
import '../../../subscription_packages/presentation/bloc/current_plan_bloc.dart';
import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../../../subscription_packages/presentation/widgets/package_widgets.dart';
import '../../sections/resume/presentation/bloc/resume_bloc.dart';
import '../../shared/widgets/profile_section.dart';

/// "My plan": the current plan from [CurrentPlanBloc] with an Upgrade or
/// Manage link, the monthly application limit, and CV uploads left
/// ([ResumeBloc] count against the plan's limit). Tapping opens the plans.
class MyPlanSection extends StatelessWidget {
  const MyPlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<CurrentPlanBloc>()..add(const CurrentPlanRequested()),
        ),
        BlocProvider(
          create: (_) => sl<ResumeBloc>()..add(const ResumesRequested()),
        ),
      ],
      child: const _MyPlanView(),
    );
  }
}

class _MyPlanView extends StatelessWidget {
  const _MyPlanView();

  /// Opens the plans, then refreshes in case the plan or CVs changed.
  Future<void> _openPlans(BuildContext context) async {
    final plan = context.read<CurrentPlanBloc>();
    final resumes = context.read<ResumeBloc>();
    await Navigator.of(context).push(SubscriptionPackagesPage.route());
    if (!plan.isClosed) plan.add(const CurrentPlanRequested());
    if (!resumes.isClosed) resumes.add(const ResumesRequested());
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'My plan',
      child: BlocBuilder<CurrentPlanBloc, CurrentPlanState>(
        builder: (context, state) {
          final sub = state.subscription;
          if (sub == null) {
            return state.status == CurrentPlanStatus.failure
                ? _Retry(
                    onRetry: () => context.read<CurrentPlanBloc>().add(
                      const CurrentPlanRequested(),
                    ),
                  )
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
          }
          return _PlanCard(subscription: sub, onTap: () => _openPlans(context));
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.subscription, required this.onTap});

  final CurrentSubscription subscription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.colors;
    final s = subscription;
    final end = s.expiresAt;
    final ending = s.isEndingSoon;

    final String action;
    if (s.isFree) {
      action = 'Upgrade';
    } else if (ending) {
      action = 'Renew';
    } else {
      action = 'Manage';
    }

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Row(
              children: [
                ProfileIconTile(
                  icon: Icons.workspace_premium_outlined,
                  size: 44,
                  background: s.isFree ? null : scheme.primary,
                  color: s.isFree ? null : scheme.onPrimary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${PackageFormat.shortName(s.package.name)} plan',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (end != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          ending
                              ? 'Ends in ${s.daysLeft()} days'
                              : 'Valid till ${PackageFormat.date(end)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: ending
                                ? Colors.orange.shade700
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                    padding: const EdgeInsets.only(left: 8),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        action,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _Counter(
                      icon: Icons.send_outlined,
                      value: PackageFormat.count(s.monthlyApplications),
                      suffix: ' / month',
                      label: 'Applications',
                    ),
                  ),
                  VerticalDivider(width: 1, color: scheme.outlineVariant),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BlocBuilder<ResumeBloc, ResumeState>(
                      buildWhen: (a, b) =>
                          a.items.length != b.items.length ||
                          a.isLoading != b.isLoading,
                      builder: (context, resumes) {
                        final limit = s.maxResumes;
                        final known = !resumes.isLoading && limit != null;
                        final left = known
                            ? (limit - resumes.items.length).clamp(0, limit)
                            : null;
                        return _Counter(
                          icon: Icons.upload_file_outlined,
                          value: left == null ? '–' : '$left',
                          suffix: limit == null ? '' : ' / $limit',
                          label: 'CV uploads left',
                          warn: left == 0,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon, a bold value with a muted suffix, and a label. Turns orange when
/// [warn] is set (nothing left).
class _Counter extends StatelessWidget {
  const _Counter({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
    this.warn = false,
  });

  final IconData icon;
  final String value;
  final String suffix;
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final strong = warn ? Colors.orange.shade700 : scheme.onSurface;
    final muted = warn ? Colors.orange.shade700 : scheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 20, color: muted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: strong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: suffix,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            "Couldn't load your plan.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

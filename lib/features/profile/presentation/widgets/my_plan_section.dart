import 'package:flutter/material.dart';

import '../../../subscription_packages/presentation/pages/subscription_packages_page.dart';
import '../../shared/widgets/profile_section.dart';

/// The candidate's current plan and what's left of its limits.
///
/// UI-only for now; will be filled from the current-plan API later.
class MyPlanSummary {
  const MyPlanSummary({
    required this.planName,
    required this.isFree,
    this.validTill,
    required this.applicationsUsed,
    required this.applicationsLimit,
    required this.cvsUploaded,
    required this.cvLimit,
  });

  final String planName;
  final bool isFree;
  final DateTime? validTill;
  final int applicationsUsed;
  final int applicationsLimit;
  final int cvsUploaded;
  final int cvLimit;

  int get applicationsLeft =>
      (applicationsLimit - applicationsUsed).clamp(0, applicationsLimit);

  int get cvsLeft => (cvLimit - cvsUploaded).clamp(0, cvLimit);

  /// Sample values for the mockup.
  static final sample = MyPlanSummary(
    planName: 'Free plan',
    isFree: true,
    validTill: DateTime(2027, 9, 14),
    applicationsUsed: 26,
    applicationsLimit: 30,
    cvsUploaded: 2,
    cvLimit: 3,
  );
}

/// "My plan": plan name and validity with an Upgrade link, then two
/// counters for applications and CV uploads left. Tapping opens the plans.
class MyPlanSection extends StatelessWidget {
  const MyPlanSection({super.key, required this.summary});

  final MyPlanSummary summary;

  void _openPlans(BuildContext context) =>
      Navigator.of(context).push(SubscriptionPackagesPage.route());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = summary;

    return ProfileSection(
      title: 'My plan',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPlans(context),
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
                          s.planName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (s.validTill != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Valid till ${_date(s.validTill!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openPlans(context),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.primary,
                      padding: const EdgeInsets.only(left: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.isFree ? 'Upgrade' : 'Manage',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
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
                        left: s.applicationsLeft,
                        total: s.applicationsLimit,
                        label: 'Applications left',
                      ),
                    ),
                    VerticalDivider(width: 1, color: scheme.outlineVariant),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Counter(
                        icon: Icons.upload_file_outlined,
                        left: s.cvsLeft,
                        total: s.cvLimit,
                        label: 'CV uploads left',
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

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// Icon, "4 / 30" and a label. Turns orange once nothing is left.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.icon,
    required this.left,
    required this.total,
    required this.label,
  });

  final IconData icon;
  final int left;
  final int total;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final empty = left == 0;
    final strong = empty ? Colors.orange.shade700 : scheme.onSurface;
    final muted = empty ? Colors.orange.shade700 : scheme.onSurfaceVariant;

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
                      text: '$left',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: strong,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' / $total',
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

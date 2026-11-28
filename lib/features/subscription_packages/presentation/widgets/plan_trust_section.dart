import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import 'plan_section.dart';

/// "Why it's safe": short promises that answer payment worries up front.
class PlanTrustSection extends StatelessWidget {
  const PlanTrustSection({super.key});

  static const _points = [
    (
      icon: Icons.shield_outlined,
      title: 'Secure payment',
      detail: 'via Razorpay · UPI, cards, netbanking',
    ),
    (
      icon: Icons.schedule_rounded,
      title: 'Cancel anytime',
      detail: 'keep your benefits till the period ends',
    ),
    (
      icon: Icons.check_circle_outline_rounded,
      title: 'No hidden charges',
      detail: 'the price you see is what you pay',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PlanSection(
      title: "Why it's safe",
      child: Column(
        children: [
          for (final p in _points)
            _TrustRow(icon: p.icon, title: p.title, detail: p.detail),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '$title  ',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:curejobs/core/utils/extensions/theme_extensions.dart';

import 'plan_section.dart';

/// Common billing questions, collapsed by default.
class PlanFaqSection extends StatelessWidget {
  const PlanFaqSection({super.key});

  static const _faqs = [
    (
      question: 'Can I cancel anytime?',
      answer:
          'Yes. Turn off auto-pay from this screen whenever you like. '
          "You won't be charged again.",
    ),
    (
      question: 'What happens when my plan ends?',
      answer:
          'If auto-pay is on, the plan renews for the same price. If it is '
          'off, you move to the Free plan. Your profile and CVs stay safe.',
    ),
    (
      question: 'Will I get a refund if I cancel?',
      answer:
          'Turning off auto-pay stops future charges. You keep every '
          'benefit until the period you paid for ends.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PlanSection(
      title: 'Questions',
      child: Column(
        children: [
          for (final (i, faq) in _faqs.indexed) ...[
            if (i > 0) Divider(height: 1, color: colors.outlineVariant),
            _FaqTile(question: faq.question, answer: faq.answer),
          ],
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    return Theme(
      // Drop ExpansionTile's own top/bottom borders; we draw dividers.
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 14),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: colors.onSurfaceVariant,
        collapsedIconColor: colors.onSurfaceVariant,
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

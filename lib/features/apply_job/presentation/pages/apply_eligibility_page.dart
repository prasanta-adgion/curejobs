import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../domain/entities/application_eligibility.dart';
import '../bloc/eligibility_cubit.dart';
import '../widgets/apply_flow_widgets.dart';
import '../widgets/eligibility_widgets.dart';
import 'choose_cv_page.dart';
import 'screening_questions_page.dart';

/// Step 1 of applying: shows what the candidate meets and what to review.
class ApplyEligibilityPage extends StatelessWidget {
  const ApplyEligibilityPage({super.key, required this.job});

  final Job job;

  static Route<void> route(Job job) =>
      MaterialPageRoute(builder: (_) => ApplyEligibilityPage(job: job));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EligibilityCubit>()..load(job.id),
      child: _EligibilityView(job: job),
    );
  }
}

class _EligibilityView extends StatelessWidget {
  const _EligibilityView({required this.job});

  final Job job;

  void _continue(BuildContext context, ApplicationEligibility e) {
    if (e.hasQuestions) {
      Navigator.of(context).push(ScreeningQuestionsPage.route(job, e));
      return;
    }
    Navigator.of(context).push(ChooseCvPage.route(job, eligibility: e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: ApplyStepAppBar(
        title: 'Before you apply',
        subtitle: '${job.title} · ${job.organization.name}',
        step: ApplyStep.eligibility,
      ),
      body: BlocBuilder<EligibilityCubit, EligibilityState>(
        builder: (context, state) => switch (state.status) {
          EligibilityLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          EligibilityLoadStatus.failure => _ErrorView(
            message: state.failure?.message ?? 'Something went wrong.',
            onRetry: () => context.read<EligibilityCubit>().load(job.id),
          ),
          EligibilityLoadStatus.success => _content(
            context,
            state.eligibility!,
          ),
        },
      ),
    );
  }

  Widget _content(BuildContext context, ApplicationEligibility e) {
    final canApply = e.status.canApply;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              ApplySection(
                child: Column(
                  children: [
                    EligibilityBanner(eligibility: e),
                    const SizedBox(height: 14),
                    EligibilityCounts(eligibility: e),
                  ],
                ),
              ),
              if (e.failed.isNotEmpty)
                _checksSection(
                  context,
                  title: 'Not met',
                  icon: Icons.cancel_outlined,
                  status: CheckStatus.fail,
                  checks: e.failed,
                ),
              // TODO: pass onAddSkills to open the profile skills screen.
              if (e.warnings.isNotEmpty)
                _checksSection(
                  context,
                  title: 'Worth a look',
                  icon: Icons.error_outline_rounded,
                  status: CheckStatus.warning,
                  checks: e.warnings,
                ),
              if (e.passed.isNotEmpty)
                _checksSection(
                  context,
                  title: "You're a match",
                  icon: Icons.check_circle_outline_rounded,
                  status: CheckStatus.pass,
                  checks: e.passed,
                ),
            ],
          ),
        ),
        ApplyBottomBar(
          child: ApplyPrimaryButton(
            onPressed: canApply ? () => _continue(context, e) : null,
            label: !canApply
                ? "Can't apply"
                : e.hasQuestions
                ? 'Continue to questions'
                : 'Continue to choose CV',
          ),
        ),
      ],
    );
  }

  /// A gap, then a full-width section: header with count, then the rows.
  Widget _checksSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required CheckStatus status,
    required List<EligibilityCheck> checks,
  }) {
    final tone = StatusTone.of(context, status);
    return Column(
      children: [
        const ApplySectionGap(),
        ApplySection(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            children: [
              ApplySectionHeader(
                icon: icon,
                iconColor: tone.foreground,
                title: title,
                trailing: _CountPill(count: checks.length, tone: tone),
              ),
              for (final c in checks) ...[
                const ApplyRowDivider(),
                EligibilityCheckTile(check: c),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count, required this.tone});

  final int count;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: tone.foreground, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

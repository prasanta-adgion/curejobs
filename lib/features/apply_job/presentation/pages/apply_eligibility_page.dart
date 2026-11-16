import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../domain/entities/application_eligibility.dart';
import '../bloc/eligibility_cubit.dart';
import '../widgets/eligibility_widgets.dart';
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
      Navigator.of(context).push(ScreeningQuestionsPage.route(job, e.questions));
      return;
    }
    // TODO: call the submit-application API once it's available.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Submit coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Before you apply'),
            Text(
              '${job.title} · ${job.organization.name}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              EligibilityBanner(eligibility: e),
              const SizedBox(height: 12),
              EligibilityCounts(eligibility: e),
              if (e.failed.isNotEmpty) ...[
                const CheckSectionTitle('Not met'),
                for (final c in e.failed) EligibilityCheckTile(check: c),
              ],
              if (e.warnings.isNotEmpty) ...[
                const CheckSectionTitle('Worth a look'),
                // TODO: pass onAddSkills to open the profile skills screen.
                for (final c in e.warnings) EligibilityCheckTile(check: c),
              ],
              if (e.passed.isNotEmpty) ...[
                const CheckSectionTitle("You're a match"),
                for (final c in e.passed) EligibilityCheckTile(check: c),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: canApply ? () => _continue(context, e) : null,
              style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
              child: Text(
                !canApply
                    ? "Can't apply"
                    : e.hasQuestions
                    ? 'Continue to questions'
                    : 'Submit application',
              ),
            ),
          ),
        ),
      ],
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

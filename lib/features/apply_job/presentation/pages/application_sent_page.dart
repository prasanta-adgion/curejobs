import 'package:curejobs/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../all_jobs/domain/entities/job.dart';
import '../../../applied_application/presentation/page/my_applications_page.dart';
import '../widgets/apply_flow_widgets.dart';
import '../widgets/eligibility_widgets.dart';
import '../../domain/entities/application_eligibility.dart';

/// Shown after the application is submitted.
class ApplicationSentPage extends StatelessWidget {
  const ApplicationSentPage({super.key, required this.job, this.sentAt});

  final Job job;
  final DateTime? sentAt;

  static Route<void> route(Job job, {DateTime? sentAt}) => MaterialPageRoute(
    builder: (_) => ApplicationSentPage(job: job, sentAt: sentAt),
  );

  void _close(BuildContext context) =>
      Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = StatusTone.of(context, CheckStatus.pass);
    final d = (sentAt ?? DateTime.now()).toLocal();

    return Scaffold(
      appBar: ApplyStepAppBar(
        title: 'Application sent',
        showBack: false,
        backgroundColor: theme.brightness == Brightness.dark
            ? AppColors.successDark.withValues(alpha: 0.35)
            : AppColors.success,
        actions: [
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _close(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: tone.background,
              child: Icon(
                Icons.check_rounded,
                size: 44,
                color: tone.foreground,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Application sent',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${job.organization.name} has your application for ${job.title}.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens next',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _NextStep(
                  done: true,
                  text:
                      'Submitted · ${d.day} ${DateTimeUtils.months[d.month - 1]} ${d.year}',
                ),
                const _NextStep(text: 'Recruiter reviews your profile'),
                const _NextStep(text: "You'll get a notification on updates"),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 52),
                backgroundColor: ApplyFlowColors.appBar(context),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final nav = Navigator.of(context);
                nav.popUntil((r) => r.isFirst);
                nav.push(
                  MaterialPageRoute(builder: (_) => const MyApplicationsPage()),
                );
              },
              child: const Text('Track application'),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => _close(context),
              child: const Text('Browse more jobs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({required this.text, this.done = false});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = StatusTone.of(context, CheckStatus.pass);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 20,
            color: done ? tone.foreground : scheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: done ? null : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

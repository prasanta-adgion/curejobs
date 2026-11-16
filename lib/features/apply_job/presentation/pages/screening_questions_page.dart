import 'package:flutter/material.dart';

import '../../../all_jobs/domain/entities/job.dart';
import '../../domain/entities/application_eligibility.dart';

/// Step 2 of applying: the recruiter's screening questions.
class ScreeningQuestionsPage extends StatefulWidget {
  const ScreeningQuestionsPage({
    super.key,
    required this.job,
    required this.questions,
  });

  final Job job;
  final List<ScreeningQuestion> questions;

  static Route<void> route(Job job, List<ScreeningQuestion> questions) =>
      MaterialPageRoute(
        builder: (_) => ScreeningQuestionsPage(job: job, questions: questions),
      );

  @override
  State<ScreeningQuestionsPage> createState() => _ScreeningQuestionsPageState();
}

class _ScreeningQuestionsPageState extends State<ScreeningQuestionsPage> {
  /// Question id → selected option id.
  final _choices = <String, String>{};

  /// Question id → text controller (short answers only).
  late final Map<String, TextEditingController> _text = {
    for (final q in widget.questions)
      if (q.type == QuestionType.shortAnswer) q.id: TextEditingController(),
  };

  /// Show "Answer this question" under empty required ones after submit.
  bool _showErrors = false;

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool _isAnswered(ScreeningQuestion q) => switch (q.type) {
    QuestionType.singleChoice => _choices.containsKey(q.id),
    QuestionType.shortAnswer => _text[q.id]!.text.trim().isNotEmpty,
    QuestionType.unknown => true,
  };

  int get _answeredCount => widget.questions.where(_isAnswered).length;

  void _submit() {
    final missing = widget.questions.where((q) => q.required && !_isAnswered(q));
    if (missing.isNotEmpty) {
      setState(() => _showErrors = true);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Answer ${missing.length} more required '
              '${missing.length == 1 ? 'question' : 'questions'}',
            ),
          ),
        );
      return;
    }
    // Answers ready to send, shaped as { questionId, optionId | answer }.
    // TODO: call the submit-application API once it's available.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Submit coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.questions.length;
    final answered = _answeredCount;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Screening questions'),
            Text(
              '$answered of $total answered',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: total == 0 ? 1 : answered / total,
            minHeight: 4,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: total,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final q = widget.questions[i];
            return _QuestionCard(
              index: i,
              question: q,
              showError: _showErrors && q.required && !_isAnswered(q),
              child: switch (q.type) {
                QuestionType.singleChoice => _ChoiceOptions(
                  options: q.options,
                  selectedId: _choices[q.id],
                  onSelected: (id) => setState(() => _choices[q.id] = id),
                ),
                QuestionType.shortAnswer => TextField(
                  controller: _text[q.id],
                  maxLength: q.maxAnswerLength,
                  minLines: 2,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Type your answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                QuestionType.unknown => const SizedBox.shrink(),
              },
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
          child: const Text('Submit application'),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.showError,
    required this.child,
  });

  final int index;
  final ScreeningQuestion question;
  final bool showError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: showError ? scheme.error : scheme.outlineVariant,
          width: showError ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}${question.required ? ' · Required' : ' · Optional'}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            question.prompt,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          child,
          if (showError) ...[
            const SizedBox(height: 6),
            Text(
              'Answer this question',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

/// Big, easy-to-tap option buttons (side by side for 2, stacked for more).
class _ChoiceOptions extends StatelessWidget {
  const _ChoiceOptions({
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  final List<QuestionOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      for (final o in options)
        _OptionButton(
          label: o.label,
          selected: o.id == selectedId,
          onTap: () => onSelected(o.id),
        ),
    ];
    if (options.length <= 2) {
      return Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: buttons[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (final b in buttons)
          Padding(padding: const EdgeInsets.only(bottom: 8), child: b),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.6)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? scheme.primary : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

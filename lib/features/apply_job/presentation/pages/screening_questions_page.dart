import 'package:curejobs/core/constants/asset_paths.dart';
import 'package:flutter/material.dart';

import '../../../all_jobs/domain/entities/job.dart';
import '../../domain/entities/application_eligibility.dart';
import '../widgets/apply_flow_widgets.dart';
import '../widgets/eligibility_widgets.dart';
import 'choose_cv_page.dart';

/// Step 2 of applying: the recruiter's screening questions.
class ScreeningQuestionsPage extends StatefulWidget {
  const ScreeningQuestionsPage({
    super.key,
    required this.job,
    required this.eligibility,
  });

  final Job job;
  final ApplicationEligibility eligibility;

  List<ScreeningQuestion> get questions => eligibility.questions;

  static Route<void> route(Job job, ApplicationEligibility eligibility) =>
      MaterialPageRoute(
        builder: (_) =>
            ScreeningQuestionsPage(job: job, eligibility: eligibility),
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

  /// Used to scroll to the first unanswered required question.
  late final Map<String, GlobalKey> _keys = {
    for (final q in widget.questions) q.id: GlobalKey(),
  };

  /// Show "Please answer this question" under empty required ones after
  /// the candidate tries to continue.
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

  List<ScreeningQuestion> get _missingRequired =>
      widget.questions.where((q) => q.required && !_isAnswered(q)).toList();

  void _submit() {
    final missing = _missingRequired;
    if (missing.isNotEmpty) {
      if (!mounted) return;
      setState(() => _showErrors = true);
      FocusScope.of(context).unfocus();
      final target = _keys[missing.first.id]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: 0.1,
        );
      }
      return;
    }
    final answers = [
      for (final q in widget.questions)
        if (_isAnswered(q) && q.type != QuestionType.unknown)
          ScreeningAnswer(
            questionId: q.id,
            optionId: _choices[q.id],
            text: _text[q.id]?.text.trim(),
          ),
    ];
    Navigator.of(context).push(
      ChooseCvPage.route(
        widget.job,
        eligibility: widget.eligibility,
        answers: answers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final total = questions.length;
    final answered = questions.where(_isAnswered).length;
    final missing = _missingRequired.length;

    return Scaffold(
      backgroundColor: ApplyFlowColors.page(context),
      appBar: ApplyStepAppBar(
        title: 'Screening questions',
        subtitle: '${widget.job.title} · ${widget.job.organization.name}',
        step: ApplyStep.questions,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ApplySection(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: _Intro(answered: answered, total: total),
            ),
            for (var i = 0; i < total; i++) ...[
              const ApplySectionGap(),
              _QuestionSection(
                key: _keys[questions[i].id],
                index: i,
                total: total,
                question: questions[i],
                answered: _isAnswered(questions[i]),
                showError:
                    _showErrors &&
                    questions[i].required &&
                    !_isAnswered(questions[i]),
                child: _answerInput(questions[i]),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: ApplyBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BottomHint(missing: missing),
            const SizedBox(height: 8),
            ApplyPrimaryButton(
              label: 'Continue to choose CV',
              // icon: Icons.arrow_forward_rounded,
              icon: Image.asset(
                AssetPaths.forwordArrow,
                width: 18,
                height: 18,
                color: Colors.white,
              ),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerInput(ScreeningQuestion q) => switch (q.type) {
    QuestionType.singleChoice => _ChoiceOptions(
      options: q.options,
      selectedId: _choices[q.id],
      onSelected: (id) {
        if (!mounted) return;
        setState(() => _choices[q.id] = id);
      },
    ),
    QuestionType.shortAnswer => _ShortAnswer(
      controller: _text[q.id]!,
      maxLength: q.maxAnswerLength,
      showError: _showErrors && q.required && !_isAnswered(q),
      onChanged: () {
        if (!mounted) return;
        setState(() {});
      },
    ),
    QuestionType.unknown => const SizedBox.shrink(),
  };
}

/// "A few questions from the recruiter" with a progress bar.
class _Intro extends StatelessWidget {
  const _Intro({required this.answered, required this.total});

  final int answered;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A few questions from the recruiter',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Your answers help them shortlist you faster.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: total == 0 ? 1 : answered / total),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: ApplyFlowColors.appBar(context),
                    backgroundColor: scheme.primaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$answered of $total answered',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Full-width section for one question: number (tick once answered),
/// "Question 1 of 3", Required/Optional pill, the prompt and the input.
class _QuestionSection extends StatelessWidget {
  const _QuestionSection({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.answered,
    required this.showError,
    required this.child,
  });

  final int index;
  final int total;
  final ScreeningQuestion question;
  final bool answered;
  final bool showError;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pass = StatusTone.of(context, CheckStatus.pass);
    final fail = StatusTone.of(context, CheckStatus.fail);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ApplyFlowColors.section(context),
        // Red bar on the left marks a question that still needs an answer.
        border: Border(
          left: BorderSide(
            color: showError ? fail.foreground : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: CircleAvatar(
                    key: ValueKey(answered),
                    radius: 13,
                    backgroundColor: answered
                        ? pass.background
                        : scheme.primaryContainer,
                    child: answered
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: pass.foreground,
                          )
                        : Text(
                            '${index + 1}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Question ${index + 1} of $total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _RequiredPill(required: question.required),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.prompt,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            child,
            if (showError && question.type != QuestionType.shortAnswer) ...[
              const SizedBox(height: 8),
              _ErrorLine(color: fail.foreground),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequiredPill extends StatelessWidget {
  const _RequiredPill({required this.required});

  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fail = StatusTone.of(context, CheckStatus.fail);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: required ? fail.background : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        required ? 'Required' : 'Optional',
        style: theme.textTheme.labelSmall?.copyWith(
          color: required ? fail.foreground : scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.error_outline_rounded, size: 16, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Please answer this question to continue',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Text box with a live character count and the error line on the same row.
class _ShortAnswer extends StatelessWidget {
  const _ShortAnswer({
    required this.controller,
    required this.maxLength,
    required this.showError,
    required this.onChanged,
  });

  final TextEditingController controller;
  final int? maxLength;
  final bool showError;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fail = StatusTone.of(context, CheckStatus.fail).foreground;
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
    final max = maxLength;

    return Column(
      children: [
        TextField(
          controller: controller,
          maxLength: max,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Type your answer',
            // Count is shown below, next to the error line.
            counterText: '',
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: showError
                ? border(fail, 1.5)
                : border(scheme.outlineVariant, 1),
            focusedBorder: border(
              showError ? fail : ApplyFlowColors.appBar(context),
              1.5,
            ),
          ),
        ),
        if (showError || max != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: showError
                    ? _ErrorLine(color: fail)
                    : const SizedBox.shrink(),
              ),
              if (max != null)
                Text(
                  '${controller.text.length} / $max',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// "1 required question left" / "All set" above the Continue button.
class _BottomHint extends StatelessWidget {
  const _BottomHint({required this.missing});

  final int missing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = missing == 0;
    final color = StatusTone.of(
      context,
      done ? CheckStatus.pass : CheckStatus.fail,
    ).foreground;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          done
              ? 'All set, you can continue'
              : '$missing required ${missing == 1 ? 'question' : 'questions'} left',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Two options side by side as big buttons (e.g. Yes / No); three or more
/// as full-width radio rows.
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
    if (options.length <= 2) {
      return Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _OptionTile(
                label: options[i].label,
                selected: options[i].id == selectedId,
                radio: false,
                onTap: () => onSelected(options[i].id),
              ),
            ),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _OptionTile(
            label: options[i].label,
            selected: options[i].id == selectedId,
            radio: true,
            onTap: () => onSelected(options[i].id),
          ),
        ],
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.radio,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Radio circle on the left (list) vs centred label with a tick (pair).
  final bool radio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = ApplyFlowColors.appBar(context);
    final text = Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: selected ? scheme.primary : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );

    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? accent : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: radio
                  ? Row(
                      children: [
                        _RadioDot(selected: selected, color: accent),
                        const SizedBox(width: 12),
                        Expanded(child: text),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selected) ...[
                          Icon(Icons.check_rounded, size: 18, color: accent),
                          const SizedBox(width: 6),
                        ],
                        Flexible(child: text),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: Border.all(
          color: selected ? color : scheme.outline,
          width: selected ? 6 : 1.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../models/skill_suggestions.dart';

/// Opens the skills editor. Returns the new list when the user taps Save, or
/// null when they close it without saving.
///
/// [suggestedFor] names who the suggestions are for, such as "ICU nurses".
Future<List<String>?> showEditSkillsSheet(
  BuildContext context, {
  required List<String> skills,
  String? suggestedFor,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Swiping or tapping outside would skip the discard prompt, so closing
    // goes through the X or back, which both ask first.
    enableDrag: false,
    isDismissible: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: (_) =>
        EditSkillsSheet(initialSkills: skills, suggestedFor: suggestedFor),
  );
}

class EditSkillsSheet extends StatefulWidget {
  const EditSkillsSheet({
    super.key,
    required this.initialSkills,
    this.suggestedFor,
  });

  final List<String> initialSkills;
  final String? suggestedFor;

  @override
  State<EditSkillsSheet> createState() => _EditSkillsSheetState();
}

class _EditSkillsSheetState extends State<EditSkillsSheet> {
  late final ValueNotifier<List<String>> _skillsNotifier;
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// True while the search field is focused or has text.
  final _searching = ValueNotifier(false);

  // Own messenger so snackbars show above the sheet, not behind it.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late final Set<String> _initialLower = {
    for (final s in widget.initialSkills) s.toLowerCase(),
  };

  @override
  void initState() {
    super.initState();
    _skillsNotifier = ValueNotifier(List<String>.of(widget.initialSkills));
    _focus.addListener(_updateSearching);
    _controller.addListener(_updateSearching);
  }

  @override
  void dispose() {
    _skillsNotifier.dispose();
    _searching.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _updateSearching() {
    _searching.value = _focus.hasFocus || _controller.text.trim().isNotEmpty;
  }

  void _exitSearch() {
    _controller.clear();
    _focus.unfocus();
  }

  bool _isFull(List<String> skills) =>
      skills.length >= SkillSuggestions.maxSkills;

  bool _isNew(String skill) => !_initialLower.contains(skill.toLowerCase());

  ({int added, int removed}) _changes(List<String> skills) {
    final current = {for (final s in skills) s.toLowerCase()};
    return (
      added: current.difference(_initialLower).length,
      removed: _initialLower.difference(current).length,
    );
  }

  bool _hasChanges(List<String> skills) {
    final initial = widget.initialSkills;
    if (initial.length != skills.length) return true;
    for (var i = 0; i < initial.length; i++) {
      if (initial[i] != skills[i]) return true;
    }
    return false;
  }

  bool _contains(String skill) =>
      _skillsNotifier.value.any((s) => s.toLowerCase() == skill.toLowerCase());

  void _add(String raw) {
    final skill = raw.trim();
    if (skill.isEmpty) return;
    if (_contains(skill)) {
      _showMessage(
        '"$skill" is already in your skills',
        type: AppSnackbarType.error,
      );
      return;
    }

    final skills = _skillsNotifier.value;
    if (_isFull(skills)) {
      _showMessage(
        'You can add up to ${SkillSuggestions.maxSkills} skills',
        type: AppSnackbarType.error,
      );
      return;
    }

    // Replace the list instead of mutating it, so listeners are notified.
    _skillsNotifier.value = [...skills, skill];
    _controller.clear();
  }

  void _remove(String skill) {
    final skills = _skillsNotifier.value;
    final index = skills.indexOf(skill);
    if (index < 0) return;

    _skillsNotifier.value = [...skills.take(index), ...skills.skip(index + 1)];

    _showMessage(
      'Removed "$skill"',
      actionLabel: 'Undo',
      onAction: () {
        if (!mounted || _contains(skill)) return;
        final current = _skillsNotifier.value;
        if (_isFull(current)) {
          _showMessage(
            'You can add up to ${SkillSuggestions.maxSkills} skills',
            type: AppSnackbarType.error,
          );
          return;
        }
        final insertAt = index.clamp(0, current.length);
        _skillsNotifier.value = [
          ...current.take(insertAt),
          skill,
          ...current.skip(insertAt),
        ];
      },
    );
  }

  /// Uses the app's snackbar style, shown on this sheet's own messenger so it
  /// appears above the sheet instead of behind it.
  void _showMessage(
    String title, {
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    AppSnackbar.show(
      type: type,
      title: title,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: const Duration(seconds: 3),
      messenger: _messengerKey.currentState,
    );
  }

  Future<void> _close() async {
    if (!_hasChanges(_skillsNotifier.value) || await _confirmDiscard()) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("Your skill changes won't be saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  void _save() =>
      Navigator.of(context)
          .pop(List<String>.unmodifiable(_skillsNotifier.value));

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.88;
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<List<String>>(
      valueListenable: _skillsNotifier,
      builder: (context, skills, _) {
        final isFull = _isFull(skills);
        final hasChanges = _hasChanges(skills);

        return PopScope(
          // Back is always handled here, so it reads the latest search state.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            // Back leaves search first, then asks before discarding.
            if (_searching.value) {
              _exitSearch();
            } else {
              _close();
            }
          },
          child: SizedBox(
            height: height,
            child: ScaffoldMessenger(
              key: _messengerKey,
              child: Scaffold(
                backgroundColor: scheme.surface,
                body: ValueListenableBuilder<bool>(
                  valueListenable: _searching,
                  builder: (context, searching, _) => Column(
                    children: [
                      const _DragHandle(),
                      if (searching)
                        _SearchBar(
                          controller: _controller,
                          focusNode: _focus,
                          enabled: !isFull,
                          onBack: _exitSearch,
                          onSubmitted: _add,
                        )
                      else ...[
                        _Header(onClose: _close),
                        _ProgressRow(count: skills.length),
                        _SearchBar(
                          controller: _controller,
                          focusNode: _focus,
                          enabled: !isFull,
                          onSubmitted: _add,
                        ),
                      ],
                      Expanded(
                        child: searching
                            ? ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _controller,
                                builder: (context, value, _) => _SearchResults(
                                  query: value.text.trim(),
                                  isAdded: _contains,
                                  onAdd: _add,
                                ),
                              )
                            : _Overview(
                                skills: skills,
                                isFull: isFull,
                                isNew: _isNew,
                                isAdded: _contains,
                                suggestedFor: widget.suggestedFor,
                                onRemove: _remove,
                                onAdd: _add,
                              ),
                      ),
                      _SaveBar(
                        changes: _changes(skills),
                        onSave: hasChanges ? _save : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: scheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your skills',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Recruiters search by these',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final max = SkillSuggestions.maxSkills;

    final (icon, label, color) = count >= SkillSuggestions.goodCount
        ? (
            Icons.check_circle_outline,
            'Good profile strength',
            AppColors.success,
          )
        : count >= 3
        ? (Icons.trending_up_rounded, 'Add a few more', scheme.primary)
        : (
            Icons.info_outline_rounded,
            'Add at least 3',
            scheme.onSurfaceVariant,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$count of $max added',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: count / max,
              minHeight: 5,
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field. With [onBack] it shows a back arrow on the left, which is
/// the full-width search mode.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onSubmitted,
    this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    final field = ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        maxLength: SkillSuggestions.maxLength,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (text) {
          onSubmitted(text);
          focusNode.requestFocus();
        },
        decoration:
            InputDecoration(
              hintText: enabled
                  ? 'Search skills, e.g. ICU care'
                  : 'Limit reached. Remove one to add more',
              counterText: '',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              prefixIcon: onBack == null
                  ? const Icon(Icons.search_rounded, size: 20)
                  : null,
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.cancel_rounded, size: 18),
                      onPressed: controller.clear,
                    ),
              border: border(scheme.outlineVariant),
              enabledBorder: border(scheme.outlineVariant),
              disabledBorder: border(
                scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              focusedBorder: border(scheme.primary, 1.5),
            ).copyWith(
              contentPadding: onBack == null
                  ? null
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(onBack == null ? 20 : 8, 14, 20, 4),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          Expanded(child: field),
        ],
      ),
    );
  }
}

class _Overview extends StatefulWidget {
  const _Overview({
    required this.skills,
    required this.isFull,
    required this.isNew,
    required this.isAdded,
    required this.onRemove,
    required this.onAdd,
    this.suggestedFor,
  });

  final List<String> skills;
  final bool isFull;
  final bool Function(String) isNew;
  final bool Function(String) isAdded;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onAdd;
  final String? suggestedFor;

  @override
  State<_Overview> createState() => _OverviewState();
}

class _OverviewState extends State<_Overview> {
  SkillCategory _tab = SkillSuggestions.suggestedTabs.first;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final suggestions = [
      for (final option in SkillSuggestions.inCategory(_tab))
        if (!widget.isAdded(option.name)) option.name,
    ];
    final forWhom = widget.suggestedFor;

    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(child: _Label('Added')),
              if (widget.skills.isNotEmpty)
                Text(
                  'Tap × to remove',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: widget.skills.isEmpty
              ? const _EmptySkills()
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in widget.skills)
                      _AddedChip(
                        label: skill,
                        isNew: widget.isNew(skill),
                        onRemove: () => widget.onRemove(skill),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 18),
        Container(height: 8, color: scheme.surfaceContainerHighest),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _Label(
            forWhom == null ? 'Suggested for you' : 'Suggested for $forWhom',
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: SkillSuggestions.suggestedTabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final tab = SkillSuggestions.suggestedTabs[i];
              return _TabPill(
                label: tab.label,
                selected: tab == _tab,
                onTap: () => setState(() => _tab = tab),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: suggestions.isEmpty
              ? Text(
                  "You've added every ${_tab.label.toLowerCase()} "
                  'suggestion. Search to find more.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in suggestions)
                      _SuggestionChip(
                        label: skill,
                        onTap: widget.isFull ? null : () => widget.onAdd(skill),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AddedChip extends StatelessWidget {
  const _AddedChip({
    required this.label,
    required this.isNew,
    required this.onRemove,
  });

  final String label;
  final bool isNew;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = scheme.onPrimaryContainer;

    return Semantics(
      label: isNew ? '$label, new' : label,
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isNew ? scheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isNew) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'New',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
            IconButton(
              tooltip: 'Remove $label',
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              icon: Icon(Icons.close_rounded, size: 16, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: 16,
                color: onTap == null ? scheme.outline : scheme.primary,
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected ? scheme.onSurface : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? scheme.onSurface : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected ? scheme.surface : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySkills extends StatelessWidget {
  const _EmptySkills();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No skills yet. Search above or tap a suggestion below.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.isAdded,
    required this.onAdd,
  });

  final String query;
  final bool Function(String) isAdded;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (query.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Text(
          'Type a skill, like "wound care" or "PALS".',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final q = query.toLowerCase();
    // Matches that start with the query come first.
    final matches =
        SkillSuggestions.catalogue
            .where((o) => o.name.toLowerCase().contains(q))
            .toList()
          ..sort((a, b) {
            final aStarts = a.name.toLowerCase().startsWith(q) ? 0 : 1;
            final bStarts = b.name.toLowerCase().startsWith(q) ? 0 : 1;
            return aStarts != bStarts
                ? aStarts - bStarts
                : a.name.compareTo(b.name);
          });
    final exact =
        matches.any((o) => o.name.toLowerCase() == q) || isAdded(query);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (matches.isNotEmpty) ...[
          const _Label('Matching skills'),
          const SizedBox(height: 4),
          for (final option in matches.take(8))
            _ResultRow(
              option: option,
              query: query,
              added: isAdded(option.name),
              onAdd: () => onAdd(option.name),
            ),
        ],
        if (!exact) ...[
          const SizedBox(height: 12),
          _CustomSkillCard(query: query, onTap: () => onAdd(query)),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.option,
    required this.query,
    required this.added,
    required this.onAdd,
  });

  final SkillOption option;
  final String query;
  final bool added;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: added ? null : onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _Highlighted(
                text: option.name,
                query: query,
                color: added ? scheme.outline : null,
              ),
            ),
            if (added) ...[
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                'Added',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ] else ...[
              Text(option.category.label, style: muted),
              const SizedBox(width: 12),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add_rounded, color: scheme.onPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomSkillCard extends StatelessWidget {
  const _CustomSkillCard({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add "$query" as your own skill',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Use this if it's not in the list",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
}

/// Shows [text] with the part matching [query] in bold.
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query, this.color});

  final String text;
  final String query;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: color);
    final start = text.toLowerCase().indexOf(query.toLowerCase());
    if (start < 0) return Text(text, style: style);
    final end = start + query.length;

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.changes, required this.onSave});

  final ({int added, int removed}) changes;
  final VoidCallback? onSave;

  String get _summary {
    final parts = [
      if (changes.added > 0) '${changes.added} added',
      if (changes.removed > 0) '${changes.removed} removed',
    ];
    // Same skills in a new order still count as a change.
    if (parts.isEmpty) return onSave == null ? 'No changes' : 'Order changed';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (onSave != null)
                      Text(
                        'Not saved yet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

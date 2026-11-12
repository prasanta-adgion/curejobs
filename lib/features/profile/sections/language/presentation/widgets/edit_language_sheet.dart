import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/language.dart';
import '../models/language_proficiency_ui.dart';

/// What the language sheet returns. [proficiency] is null when it was
/// removed.
class LanguageSheetResult {
  const LanguageSheetResult.saved({
    required this.name,
    required LanguageProficiency this.proficiency,
  });
  const LanguageSheetResult.removed() : name = '', proficiency = null;

  final String name;
  final LanguageProficiency? proficiency;

  bool get isRemoved => proficiency == null;
}

/// Opens the add or edit language sheet. Pass [initial] to edit one, and
/// [taken] with names already on the profile so they can't be added twice.
/// Returns null when closed without changes.
Future<LanguageSheetResult?> showEditLanguageSheet(
  BuildContext context, {
  Language? initial,
  required List<String> taken,
}) {
  return showModalBottomSheet<LanguageSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _EditLanguageSheet(initial: initial, taken: taken),
  );
}

const _commonLanguages = [
  'Assamese',
  'Bengali',
  'English',
  'Gujarati',
  'Hindi',
  'Kannada',
  'Malayalam',
  'Marathi',
  'Nepali',
  'Odia',
  'Punjabi',
  'Tamil',
  'Telugu',
  'Urdu',
];

class _EditLanguageSheet extends StatefulWidget {
  const _EditLanguageSheet({this.initial, required this.taken});

  final Language? initial;
  final List<String> taken;

  @override
  State<_EditLanguageSheet> createState() => _EditLanguageSheetState();
}

class _EditLanguageSheetState extends State<_EditLanguageSheet> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _level = ValueNotifier<LanguageProficiency?>(
    widget.initial?.proficiency,
  );
  final _nameError = ValueNotifier<String?>(null);

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _name.dispose();
    _level.dispose();
    _nameError.dispose();
    super.dispose();
  }

  bool _isTaken(String name) {
    final lower = name.toLowerCase();
    if (_isEditing && widget.initial!.name.toLowerCase() == lower) return false;
    return widget.taken.any((t) => t.toLowerCase() == lower);
  }

  void _pick(String language) {
    _name.text = language;
    _nameError.value = null;
  }

  void _save() {
    final name = _name.text.trim();
    final level = _level.value;
    final error = name.isEmpty
        ? 'Enter a language'
        : _isTaken(name)
        ? '$name is already on your profile'
        : null;
    _nameError.value = error;
    if (error != null || level == null) return;

    Navigator.of(context)
        .pop(LanguageSheetResult.saved(name: name, proficiency: level));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = _commonLanguages.where((l) => !_isTaken(l)).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(isEditing: _isEditing),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _Label('LANGUAGE'),
                  const SizedBox(height: 8),
                  if (_isEditing)
                    _LockedField(name: widget.initial!.name)
                  else
                    ValueListenableBuilder<String?>(
                      valueListenable: _nameError,
                      builder: (context, error, _) => TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => _nameError.value = null,
                        decoration: InputDecoration(
                          hintText: 'e.g. Hindi',
                          errorText: error,
                          prefixIcon: const Icon(
                            Icons.translate_rounded,
                            size: 20,
                          ),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _name,
                            builder: (_, value, _) => value.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(AppIcons.close, size: 18),
                                    onPressed: () => _pick(''),
                                  ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: scheme.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (!_isEditing && available.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Or pick one',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Only the chips redraw as the user types.
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _name,
                      builder: (context, value, _) {
                        final typed = value.text.trim().toLowerCase();
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final lang in available)
                              _LanguageChip(
                                label: lang,
                                selected: typed == lang.toLowerCase(),
                                onTap: () => _pick(lang),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _Label('HOW WELL DO YOU SPEAK IT?'),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<LanguageProficiency?>(
                    valueListenable: _level,
                    builder: (context, selected, _) =>
                        RadioGroup<LanguageProficiency>(
                          groupValue: selected,
                          onChanged: (v) => _level.value = v,
                          child: Column(
                            children: [
                              for (final level in LanguageProficiency.values)
                                _LevelOption(
                                  level: level,
                                  selected: level == selected,
                                  onTap: () => _level.value = level,
                                ),
                            ],
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<LanguageProficiency?>(
            valueListenable: _level,
            builder: (context, level, _) => _BottomBar(
              isEditing: _isEditing,
              onRemove: () =>
                  Navigator.of(context)
                      .pop(const LanguageSheetResult.removed()),
              onSave: level == null ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit language' : 'Add language',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEditing
                      ? 'Change your level or remove it'
                      : 'Hospitals often filter by language',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(AppIcons.close, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
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
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

/// The language name in edit mode. It can't change, so it's shown as a
/// plain grey box with a lock rather than a disabled text field.
class _LockedField extends StatelessWidget {
  const _LockedField({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.translate_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.lock_outline_rounded, size: 18, color: scheme.outline),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'To change the language, remove it and add a new one.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
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
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.6)
          : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.fromLTRB(selected ? 8 : 12, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 16, color: scheme.primary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected ? scheme.primary : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelOption extends StatelessWidget {
  const _LevelOption({
    required this.level,
    required this.selected,
    required this.onTap,
  });

  final LanguageProficiency level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 12, 2),
            child: Row(
              children: [
                Radio<LanguageProficiency>(value: level),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? scheme.primary : null,
                        ),
                      ),
                      Text(
                        level.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: selected ? 1 : 0,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isEditing,
    required this.onRemove,
    required this.onSave,
  });

  final bool isEditing;
  final VoidCallback onRemove;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
              if (isEditing) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Remove'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(isEditing ? 'Save' : 'Add language'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

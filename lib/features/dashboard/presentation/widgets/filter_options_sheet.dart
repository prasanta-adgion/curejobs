import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';

/// Bottom sheet listing filter options. Multi-select shows checkboxes,
/// single-select shows radio buttons. Returns the new selection, or null
/// when dismissed without applying.
class FilterOptionsSheet<T> extends StatefulWidget {
  const FilterOptionsSheet({
    super.key,
    required this.title,
    required this.options,
    required this.labelOf,
    required this.selected,
    this.multiSelect = false,
  });

  final String title;
  final List<T> options;
  final String Function(T option) labelOf;
  final Set<T> selected;
  final bool multiSelect;

  static Future<Set<T>?> show<T>(
    BuildContext context, {
    required String title,
    required List<T> options,
    required String Function(T option) labelOf,
    required Set<T> selected,
    bool multiSelect = false,
  }) {
    return showModalBottomSheet<Set<T>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      builder: (_) => FilterOptionsSheet<T>(
        title: title,
        options: options,
        labelOf: labelOf,
        selected: selected,
        multiSelect: multiSelect,
      ),
    );
  }

  @override
  State<FilterOptionsSheet<T>> createState() => _FilterOptionsSheetState<T>();
}

class _FilterOptionsSheetState<T> extends State<FilterOptionsSheet<T>> {
  late final _selected = ValueNotifier<Set<T>>({...widget.selected});

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  void _toggle(T option) {
    final current = _selected.value;
    if (widget.multiSelect) {
      _selected.value = current.contains(option)
          ? ({...current}..remove(option))
          : {...current, option};
    } else {
      _selected.value = current.contains(option) ? {} : {option};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(widget.title, style: theme.textTheme.titleMedium),
              ),
              const Spacer(),
              ValueListenableBuilder(
                valueListenable: _selected,
                builder: (context, selected, _) => TextButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => _selected.value = {},
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final option in widget.options)
            ValueListenableBuilder(
              valueListenable: _selected,
              builder: (context, selected, _) => _OptionTile(
                label: widget.labelOf(option),
                selected: selected.contains(option),
                multiSelect: widget.multiSelect,
                onTap: () => _toggle(option),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_selected.value),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.medium);

    return Material(
      color: selected ? scheme.primaryContainer : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 14, right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: multiSelect
                      ? Checkbox(value: selected, onChanged: (_) => onTap())
                      : Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                ),
                if (!multiSelect) const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

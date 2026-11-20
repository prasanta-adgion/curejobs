import 'package:flutter/material.dart';

import '../../../create_account/domain/entities/location_suggestion.dart';
import '../../../create_account/domain/enums/location_type.dart';
import '../../../create_account/presentation/widgets/location_autocomplete_field.dart';
import '../../domain/entities/job_alert_preferences.dart';

/// One row in [showMultiSelectSheet].
class SheetOption {
  const SheetOption({required this.id, required this.label, this.subtitle});

  final String id;
  final String label;
  final String? subtitle;
}

/// Searchable checklist in a bottom sheet. Returns the chosen ids when the
/// user taps Done, or null if they close it.
Future<List<String>?> showMultiSelectSheet(
  BuildContext context, {
  required String title,
  required String searchHint,
  required List<SheetOption> options,
  required List<String> selected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _MultiSelectSheet(
      title: title,
      searchHint: searchHint,
      options: options,
      selected: selected,
    ),
  );
}

class _MultiSelectSheet extends StatefulWidget {
  const _MultiSelectSheet({
    required this.title,
    required this.searchHint,
    required this.options,
    required this.selected,
  });

  final String title;
  final String searchHint;
  final List<SheetOption> options;
  final List<String> selected;

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  late final _selected = ValueNotifier<Set<String>>({...widget.selected});
  final _query = ValueNotifier<String>('');

  @override
  void dispose() {
    _selected.dispose();
    _query.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    final next = {..._selected.value};
    if (!next.remove(id)) next.add(id);
    _selected.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => _query.value = v,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([_query, _selected]),
              builder: (context, _) {
                final q = _query.value.trim().toLowerCase();
                final items = q.isEmpty
                    ? widget.options
                    : widget.options
                          .where((o) => o.label.toLowerCase().contains(q))
                          .toList();
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'Nothing matches "${_query.value.trim()}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: controller,
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final o = items[i];
                    return CheckboxListTile(
                      value: _selected.value.contains(o.id),
                      onChanged: (_) => _toggle(o.id),
                      title: Text(o.label),
                      subtitle: o.subtitle == null ? null : Text(o.subtitle!),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                );
              },
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: _selected,
                  builder: (context, selected, _) => SizedBox(
                    height: 50,
                    child: FilledButton(
                      // Keeps the original order, then new picks.
                      onPressed: () => Navigator.of(context).pop([
                        for (final o in widget.options)
                          if (selected.contains(o.id)) o.id,
                      ]),
                      child: Text(
                        selected.isEmpty
                            ? 'Done · none selected'
                            : 'Done · ${selected.length} selected',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for a city (state optional) or, when [wholeState], a state only.
Future<AlertLocation?> showLocationSheet(
  BuildContext context, {
  required bool wholeState,
}) {
  return showModalBottomSheet<AlertLocation>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _LocationSheet(wholeState: wholeState),
  );
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet({required this.wholeState});

  final bool wholeState;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  final _city = TextEditingController();
  final _state = TextEditingController();

  /// Shown under the fields when the required one is empty.
  final _error = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _city.addListener(_clearError);
    _state.addListener(_clearError);
  }

  @override
  void dispose() {
    _city.dispose();
    _state.dispose();
    _error.dispose();
    super.dispose();
  }

  void _clearError() => _error.value = null;

  String? _clean(String text) {
    final s = text.trim();
    return s.isEmpty ? null : s;
  }

  /// Picking a city suggestion also fills its state.
  void _onCityPicked(LocationSuggestion s) {
    final state = s.state;
    if (state != null && state.trim().isNotEmpty) _state.text = state;
  }

  void _submit() {
    final whole = widget.wholeState;
    final city = whole ? null : _clean(_city.text);
    final state = _clean(_state.text);
    if (!whole && city == null) {
      _error.value = 'Enter a city';
      return;
    }
    if (whole && state == null) {
      _error.value = 'Enter a state';
      return;
    }
    Navigator.of(context).pop(AlertLocation(city: city, state: state));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final whole = widget.wholeState;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            whole ? 'Add a whole state' : 'Add a city',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            whole
                ? 'You\'ll hear about jobs in every city of this state.'
                : 'Add the state too, so a city with the same name '
                      'elsewhere doesn\'t match.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Same suggestion fields as account creation.
          if (!whole) ...[
            LocationAutocompleteField(
              label: 'City',
              hint: 'Kolkata',
              type: LocationType.city,
              controller: _city,
              onSelected: _onCityPicked,
            ),
            const SizedBox(height: 12),
          ],
          LocationAutocompleteField(
            label: 'State',
            hint: 'West Bengal',
            type: LocationType.state,
            controller: _state,
            isOptional: !whole,
          ),
          ValueListenableBuilder<String?>(
            valueListenable: _error,
            builder: (context, error, _) => error == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton(onPressed: _submit, child: const Text('Add')),
          ),
        ],
      ),
    );
  }
}

import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../category/presentation/widgets/category_tile.dart'
    show categoryIcon, SelectionMark;
import '../../domain/entities/specialization.dart';
import '../bloc/specializations_bloc.dart';

/// Lists the chosen category's specializations. Tapping a row selects it;
/// "Continue with …" closes with it. Expects a [SpecializationsBloc] above.
///
/// [SpecializationPage.multi]: several choices from an already loaded list
/// (may span categories), pops the chosen ids as `List<String>`. Needs no
/// bloc.
class SpecializationPage extends StatelessWidget {
  const SpecializationPage({
    super.key,
    required this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.selectedId,
  }) : multiSelect = false,
       specializations = null,
       groupLabels = const {},
       selectedIds = const [];

  const SpecializationPage.multi({
    super.key,
    required List<Specialization> this.specializations,
    this.groupLabels = const {},
    this.selectedIds = const [],
  }) : multiSelect = true,
       categoryId = '',
       categoryName = null,
       categorySlug = null,
       selectedId = null;

  final bool multiSelect;

  /// Preloaded specializations (multi mode). When null, reads
  /// [SpecializationsBloc].
  final List<Specialization>? specializations;

  /// Specialization id → label shown on its row, e.g. its category name.
  final Map<String, String> groupLabels;

  /// The specializations to mark as currently chosen (multi mode).
  final List<String> selectedIds;

  /// The category to reload when the user retries.
  final String categoryId;

  /// Shown at the top so the user knows which category they're in.
  final String? categoryName;

  /// Picks the category icon at the top.
  final String? categorySlug;

  /// The specialization to mark as currently chosen.
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preloaded = specializations;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: AppBackButton.leadingOf(context),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              multiSelect
                  ? 'Choose specializations'
                  : 'Choose your specialization',
            ),
            Text(
              multiSelect
                  ? 'Pick one or more. Leave empty for all of them.'
                  : 'Your main area of focus within the category.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: preloaded != null
          ? (preloaded.isEmpty
                ? const _EmptyMessage(
                    icon: Icons.inbox_outlined,
                    title: 'No specializations yet',
                    message: 'Try different categories.',
                  )
                : _SpecializationPicker(
                    specializations: preloaded,
                    multiSelect: true,
                    selectedIds: selectedIds,
                    groupLabels: groupLabels,
                  ))
          : _blocBody(),
    );
  }

  Widget _blocBody() {
    return BlocBuilder<SpecializationsBloc, SpecializationsState>(
      builder: (context, state) {
        final failure = state.failure;
        if (state.specializations.isNotEmpty) {
          return _SpecializationPicker(
            specializations: state.specializations,
            selectedId: selectedId,
            categoryName: categoryName,
            categorySlug: categorySlug,
            multiSelect: multiSelect,
            selectedIds: selectedIds,
            groupLabels: groupLabels,
          );
        }
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (failure != null) {
          return AppErrorView(
            failure: failure,
            onRetry: () => context.read<SpecializationsBloc>().add(
              SpecializationsRequested(categoryId),
            ),
          );
        }
        return _EmptyMessage(
          icon: Icons.inbox_outlined,
          title: 'No specializations yet',
          message: categoryName == null
              ? 'Try a different category.'
              : 'There are none in $categoryName yet. Try a different '
                    'category.',
        );
      },
    );
  }
}

class _SpecializationPicker extends StatefulWidget {
  const _SpecializationPicker({
    required this.specializations,
    this.selectedId,
    this.categoryName,
    this.categorySlug,
    this.multiSelect = false,
    this.selectedIds = const [],
    this.groupLabels = const {},
  });

  final List<Specialization> specializations;
  final String? selectedId;
  final String? categoryName;
  final String? categorySlug;
  final bool multiSelect;
  final List<String> selectedIds;
  final Map<String, String> groupLabels;

  @override
  State<_SpecializationPicker> createState() => _SpecializationPickerState();
}

class _SpecializationPickerState extends State<_SpecializationPicker> {
  late final _selected = ValueNotifier<Set<String>>(
    widget.multiSelect
        ? {...widget.selectedIds}
        : {if (widget.selectedId != null) widget.selectedId!},
  );
  final _query = ValueNotifier<String>('');
  final _search = TextEditingController();

  void _tap(String id) {
    if (!widget.multiSelect) {
      _selected.value = {id};
      return;
    }
    final next = {..._selected.value};
    if (!next.remove(id)) next.add(id);
    _selected.value = next;
  }

  void _confirm(Set<String> selected) {
    if (widget.multiSelect) {
      Navigator.of(context).pop(<String>[
        for (final s in widget.specializations)
          if (selected.contains(s.id)) s.id,
      ]);
      return;
    }
    final item = _byId(selected.firstOrNull);
    if (item != null) Navigator.of(context).pop(item);
  }

  @override
  void dispose() {
    _selected.dispose();
    _query.dispose();
    _search.dispose();
    super.dispose();
  }

  List<Specialization> _filter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return widget.specializations;
    return [
      for (final item in widget.specializations)
        if (item.name.toLowerCase().contains(q) ||
            (item.description?.toLowerCase().contains(q) ?? false))
          item,
    ];
  }

  Specialization? _byId(String? id) {
    for (final item in widget.specializations) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final categoryName = widget.categoryName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (categoryName != null)
          _CategoryStrip(
            name: categoryName,
            slug: widget.categorySlug,
            count: widget.specializations.length,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            categoryName == null ? 16 : 4,
            16,
            8,
          ),
          child: TextField(
            controller: _search,
            onChanged: (value) => _query.value = value,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search, like ICU or cardiac',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, query, _) => query.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(AppIcons.close),
                        onPressed: () {
                          _search.clear();
                          _query.value = '';
                        },
                      ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([_query, _selected]),
            builder: (context, _) {
              final items = _filter(_query.value);
              if (items.isEmpty) {
                return _EmptyMessage(
                  icon: Icons.search_off_rounded,
                  title: 'No match for "${_query.value.trim()}"',
                  message: 'Try a shorter or different word.',
                );
              }
              return ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _SpecializationTile(
                    specialization: item,
                    selected: _selected.value.contains(item.id),
                    multiSelect: widget.multiSelect,
                    groupLabel: widget.groupLabels[item.id],
                    onTap: () => _tap(item.id),
                  );
                },
              );
            },
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: _selected,
                builder: (context, ids, _) {
                  final single = _byId(ids.firstOrNull);
                  final enabled = widget.multiSelect || single != null;
                  final label = widget.multiSelect
                      ? (ids.isEmpty
                            ? 'Done · none selected'
                            : 'Done · ${ids.length} selected')
                      : (single == null
                            ? 'Select a specialization'
                            : 'Continue with ${single.name}');
                  return SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: enabled ? () => _confirm(ids) : null,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: enabled ? scheme.onPrimary : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "In Nursing · 8 options   Change". Change goes back to the form, where
/// the category can be picked again.
class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.name, required this.count, this.slug});

  final String name;
  final String? slug;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            categoryIcon(slug ?? name),
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'In ',
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' · $count ${count == 1 ? 'option' : 'options'}',
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

class _SpecializationTile extends StatelessWidget {
  const _SpecializationTile({
    required this.specialization,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
    this.groupLabel,
  });

  final Specialization specialization;
  final bool selected;
  final VoidCallback onTap;
  final bool multiSelect;

  /// Small caption under the name, e.g. the category it belongs to.
  final String? groupLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final description = specialization.description?.trim();

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.45)
            : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specialization.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? scheme.primary : scheme.onSurface,
                        ),
                      ),
                      if (groupLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          groupLabel!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                          ),
                        ),
                      ],
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SelectionMark(selected: selected, square: multiSelect),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

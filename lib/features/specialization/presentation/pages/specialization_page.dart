import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../category/presentation/widgets/category_tile.dart'
    show categoryIcon;
import '../../domain/entities/specialization.dart';
import '../bloc/specializations_bloc.dart';

/// Lists the chosen category's specializations. Tapping a row selects it;
/// "Continue with …" closes with it. Expects a [SpecializationsBloc] above.
class SpecializationPage extends StatelessWidget {
  const SpecializationPage({
    super.key,
    required this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.selectedId,
  });

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

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose your specialization'),
            Text(
              'Your main area of focus within the category.',
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
      body: BlocBuilder<SpecializationsBloc, SpecializationsState>(
        builder: (context, state) {
          final failure = state.failure;
          if (state.specializations.isNotEmpty) {
            return _SpecializationPicker(
              specializations: state.specializations,
              selectedId: selectedId,
              categoryName: categoryName,
              categorySlug: categorySlug,
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
      ),
    );
  }
}

class _SpecializationPicker extends StatefulWidget {
  const _SpecializationPicker({
    required this.specializations,
    this.selectedId,
    this.categoryName,
    this.categorySlug,
  });

  final List<Specialization> specializations;
  final String? selectedId;
  final String? categoryName;
  final String? categorySlug;

  @override
  State<_SpecializationPicker> createState() => _SpecializationPickerState();
}

class _SpecializationPickerState extends State<_SpecializationPicker> {
  late final _selectedId = ValueNotifier<String?>(widget.selectedId);
  final _query = ValueNotifier<String>('');
  final _search = TextEditingController();

  @override
  void dispose() {
    _selectedId.dispose();
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
            listenable: Listenable.merge([_query, _selectedId]),
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
                    selected: item.id == _selectedId.value,
                    onTap: () => _selectedId.value = item.id,
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
              child: ValueListenableBuilder<String?>(
                valueListenable: _selectedId,
                builder: (context, id, _) {
                  final selected = _byId(id);
                  return SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: selected == null
                          ? null
                          : () => Navigator.of(context).pop(selected),
                      child: Text(
                        selected == null
                            ? 'Select a specialization'
                            : 'Continue with ${selected.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected == null ? null : scheme.onPrimary,
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
  });

  final Specialization specialization;
  final bool selected;
  final VoidCallback onTap;

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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outline,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: scheme.onPrimary,
                        )
                      : null,
                ),
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

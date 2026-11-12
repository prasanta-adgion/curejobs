import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Searchable list of categories with a confirm button.
///
/// Tapping a row only selects it; "Continue with …" pops the chosen
/// [Category], so a mis-tap never changes the answer.
class CategoryList extends StatefulWidget {
  const CategoryList({super.key, required this.categories, this.selectedId});

  final List<Category> categories;
  final String? selectedId;

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
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

  List<Category> _filter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return widget.categories;
    return [
      for (final category in widget.categories)
        if (category.name.toLowerCase().contains(q) ||
            (category.description?.toLowerCase().contains(q) ?? false))
          category,
    ];
  }

  Category? _byId(String? id) {
    for (final category in widget.categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (value) => _query.value = value,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search categories',
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
                return _NoResults(query: _query.value.trim());
              }
              return ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = items[index];
                  return CategoryTile(
                    category: category,
                    selected: category.id == _selectedId.value,
                    onTap: () => _selectedId.value = category.id,
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
                            ? 'Select a category'
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

/// One category card: icon, name, short description and a radio mark.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final description = category.description?.trim();

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
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.surface
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon(category.slug),
                    size: 22,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
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
                _RadioMark(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
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
          ? Icon(Icons.check_rounded, size: 15, color: scheme.onPrimary)
          : null,
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

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
            Icon(Icons.search_off_rounded, size: 40, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'No categories match "$query"',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Try a shorter or different word.',
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

/// The API sends no icon, so pick one from words in the slug.
IconData categoryIcon(String slug) {
  final s = slug.toLowerCase();
  bool has(List<String> words) => words.any(s.contains);

  if (has(['nurs', 'midwi'])) return Icons.monitor_heart_outlined;
  if (has(['pharm'])) return Icons.medication_outlined;
  if (has(['doctor', 'physician', 'medic', 'consult'])) {
    return Icons.medical_services_outlined;
  }
  if (has(['dent'])) return Icons.sentiment_satisfied_alt_outlined;
  if (has(['lab', 'patho', 'diagnos'])) return Icons.biotech_outlined;
  if (has(['radio', 'imaging', 'scan']))
    return Icons.settings_overscan_outlined;
  if (has(['physio', 'therap', 'rehab', 'allied'])) {
    return Icons.accessibility_new_rounded;
  }
  if (has(['admin', 'manage', 'office', 'reception'])) {
    return Icons.badge_outlined;
  }
  if (has(['emergen', 'paramed', 'ambul'])) return Icons.emergency_outlined;
  return Icons.local_hospital_outlined;
}

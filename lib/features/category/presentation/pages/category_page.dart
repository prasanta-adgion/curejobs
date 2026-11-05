import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';

/// Lists the job categories and closes with the one the user taps. Expects a
/// [CategoriesBloc] above it.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, this.selectedId});

  /// The category to mark as currently chosen.
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
            const Text('Category'),
            Text(
              'Pick the area you work in',
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
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          final failure = state.failure;
          if (state.categories.isNotEmpty) {
            return _CategoryList(
              categories: state.categories,
              selectedId: selectedId,
            );
          }
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (failure != null) {
            return AppErrorView(
              failure: failure,
              onRetry: () => context.read<CategoriesBloc>().add(
                const CategoriesRequested(),
              ),
            );
          }
          return Center(
            child: Text(
              'No categories to choose from',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories, this.selectedId});

  final List<Category> categories;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 20, color: scheme.outlineVariant),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category.id == selectedId;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(category.name),
          selected: selected,
          selectedColor: scheme.primary,
          trailing: selected
              ? Icon(Icons.check_rounded, color: scheme.primary)
              : null,
          onTap: () => Navigator.of(context).pop(category),
        );
      },
    );
  }
}

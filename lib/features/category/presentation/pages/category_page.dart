import 'package:curejobs/features/category/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../domain/entities/category.dart';
import '../bloc/categories_bloc.dart';

/// Category picker.
///
/// Default: single choice, pops a [Category]. Expects a [CategoriesBloc]
/// above.
///
/// [CategoryPage.multi]: several choices from an already loaded list, pops
/// the chosen ids as `List<String>`. Needs no bloc.
class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key, this.selectedId})
    : multiSelect = false,
      categories = null,
      selectedIds = const [];

  const CategoryPage.multi({
    super.key,
    required List<Category> this.categories,
    this.selectedIds = const [],
  }) : multiSelect = true,
       selectedId = null;

  /// The category to mark as currently chosen (single mode).
  final String? selectedId;

  final bool multiSelect;

  /// Preloaded categories (multi mode). When null, reads [CategoriesBloc].
  final List<Category>? categories;

  /// The categories to mark as currently chosen (multi mode).
  final List<String> selectedIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preloaded = categories;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: AppBackButton.leadingOf(context),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(multiSelect ? 'Choose categories' : 'Choose your category'),
            Text(
              multiSelect
                  ? 'Pick one or more. Leave empty for every category.'
                  : 'Pick the field you work in. You can change it later.',
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
                ? _empty(theme, scheme)
                : CategoryList(
                    categories: preloaded,
                    multiSelect: multiSelect,
                    selectedIds: selectedIds,
                  ))
          : BlocBuilder<CategoriesBloc, CategoriesState>(
              builder: (context, state) {
                final failure = state.failure;
                if (state.categories.isNotEmpty) {
                  return CategoryList(
                    categories: state.categories,
                    selectedId: selectedId,
                    multiSelect: multiSelect,
                    selectedIds: selectedIds,
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
                return _empty(theme, scheme);
              },
            ),
    );
  }

  Widget _empty(ThemeData theme, ColorScheme scheme) => Center(
    child: Text(
      'No categories to choose from',
      style: theme.textTheme.bodyLarge?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
  );
}

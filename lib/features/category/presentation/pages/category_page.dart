import 'package:curejobs/features/category/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../bloc/categories_bloc.dart';

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
            const Text('Choose your category'),
            Text(
              'Pick the field you work in. You can change it later.',
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
            return CategoryList(
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

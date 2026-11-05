import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/app_error_view.dart';
import '../../domain/entities/specialization.dart';
import '../bloc/specializations_bloc.dart';

/// Lists the chosen category's specializations and closes with the one the
/// user taps. Expects a [SpecializationsBloc] above it.
class SpecializationPage extends StatelessWidget {
  const SpecializationPage({
    super.key,
    required this.categoryId,
    this.selectedId,
  });

  /// The category to reload when the user retries.
  final String categoryId;

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
            const Text('Specialization'),
            Text(
              'Pick your area of focus',
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
            return _SpecializationList(
              specializations: state.specializations,
              selectedId: selectedId,
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
          return Center(
            child: Text(
              'No specializations to choose from',
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

class _SpecializationList extends StatelessWidget {
  const _SpecializationList({required this.specializations, this.selectedId});

  final List<Specialization> specializations;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: specializations.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 20, color: scheme.outlineVariant),
      itemBuilder: (context, index) {
        final specialization = specializations[index];
        final selected = specialization.id == selectedId;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: Text(specialization.name),
          selected: selected,
          selectedColor: scheme.primary,
          trailing: selected
              ? Icon(Icons.check_rounded, color: scheme.primary)
              : null,
          onTap: () => Navigator.of(context).pop(specialization),
        );
      },
    );
  }
}

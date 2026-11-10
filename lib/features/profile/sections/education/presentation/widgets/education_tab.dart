import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/education.dart';
import '../bloc/education_bloc.dart';

/// Education tab: owns its [EducationBloc] and loads from the API.
class EducationTab extends StatelessWidget {
  const EducationTab({super.key, this.onAdd, this.onEdit});

  final VoidCallback? onAdd;
  final ValueChanged<Education>? onEdit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EducationBloc>()..add(const EducationRequested()),
      child: BlocBuilder<EducationBloc, EducationState>(
        builder: (context, state) {
          if (state.isLoading && state.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == EducationStatus.failure && state.items.isEmpty) {
            return AppErrorView(
              failure: state.failure!,
              onRetry: () =>
                  context.read<EducationBloc>().add(const EducationRequested()),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<EducationBloc>()
                ..add(const EducationRequested());
              await bloc.stream.firstWhere((s) => !s.isLoading);
            },
            child: _EducationList(
              items: state.items,
              onAdd: onAdd,
              onEdit: onEdit,
            ),
          );
        },
      ),
    );
  }
}

class _EducationList extends StatelessWidget {
  const _EducationList({required this.items, this.onAdd, this.onEdit});

  final List<Education> items;
  final VoidCallback? onAdd;
  final ValueChanged<Education>? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: 'Education',
          showDivider: false,
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: onAdd,
          ),
          child: items.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No education added yet.',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: scheme.outlineVariant),
                      _EducationTile(
                        item: items[i],
                        onEdit: onEdit == null ? null : () => onEdit!(items[i]),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _EducationTile extends StatelessWidget {
  const _EducationTile({required this.item, this.onEdit});

  final Education item;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final field = item.fieldOfStudy;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileIconTile(icon: Icons.school_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field == null || field.isEmpty
                      ? item.degree
                      : '${item.degree} · $field',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(item.institution, style: muted),
                if (item.period.isNotEmpty) Text(item.period, style: muted),
                if (item.description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.description!,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 18, color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/education.dart';
import '../bloc/education_bloc.dart';

/// Education list: owns its [EducationBloc] and loads from the API.
///
/// [leading] widgets go above the Education section and [trailing] below it,
/// so other sections can share the same scrolling page. Loading and errors
/// only affect the Education section, never the extra widgets.
///
/// Read-only for now: Add and Edit show once the education form is built.
class EducationTab extends StatelessWidget {
  const EducationTab({
    super.key,
    this.leading = const [],
    this.trailing = const [],
  });

  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EducationBloc>()..add(const EducationRequested()),
      child: BlocBuilder<EducationBloc, EducationState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<EducationBloc>()
                ..add(const EducationRequested());
              await bloc.stream.firstWhere((s) => !s.isLoading);
            },
            child: _EducationList(
              state: state,
              leading: leading,
              trailing: trailing,
            ),
          );
        },
      ),
    );
  }
}

class _EducationList extends StatelessWidget {
  const _EducationList({
    required this.state,
    required this.leading,
    required this.trailing,
  });

  final EducationState state;
  final List<Widget> leading;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = state.items;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ...leading,
        ProfileSection(
          title: 'Education',
          showDivider: false,
          child: state.isLoading && items.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : state.status == EducationStatus.failure && items.isEmpty
              ? AppErrorView(
                  failure: state.failure!,
                  onRetry: () => context.read<EducationBloc>().add(
                    const EducationRequested(),
                  ),
                )
              : items.isEmpty
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
                      _EducationTile(item: items[i]),
                    ],
                  ],
                ),
        ),
        ...trailing,
      ],
    );
  }
}

class _EducationTile extends StatelessWidget {
  const _EducationTile({required this.item});

  final Education item;

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
        ],
      ),
    );
  }
}

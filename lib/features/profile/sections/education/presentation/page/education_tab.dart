import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_error_view.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/education.dart';
import '../bloc/education_bloc.dart';
import '../widgets/delete_education_sheet.dart';
import 'edit_education_form_page.dart';
import '../widgets/education_tile.dart';

/// Education list: owns its [EducationBloc], loads from the API, and adds,
/// edits or deletes entries.
///
/// [leading] widgets go above the Education section and [trailing] below it,
/// so other sections can share the same scrolling page. Loading and errors
/// only affect the Education section, never the extra widgets.
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
      child: _EducationView(leading: leading, trailing: trailing),
    );
  }
}

class _EducationView extends StatelessWidget {
  const _EducationView({required this.leading, required this.trailing});

  final List<Widget> leading;
  final List<Widget> trailing;

  Future<void> _openForm(BuildContext context, [Education? existing]) async {
    final bloc = context.read<EducationBloc>();
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EducationFormPage(education: existing)),
    );
    if (changed ?? false) bloc.add(const EducationRequested());
  }

  Future<void> _confirmDelete(BuildContext context, Education item) async {
    final bloc = context.read<EducationBloc>();
    if (await showDeleteEducationSheet(context, item)) {
      bloc.add(EducationDeleted(item));
    }
  }

  void _onStateChanged(BuildContext context, EducationState state) {
    final failure = state.actionFailure;
    if (failure != null) {
      AppSnackbar.error(
        title: "Couldn't update your education",
        message: failure.message,
      );
      return;
    }
    if (state.deleted) {
      AppSnackbar.info(
        title: 'Education deleted',
        icon: Icons.delete_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EducationBloc, EducationState>(
      listenWhen: (prev, curr) =>
          curr.deleted ||
          (curr.actionFailure != null &&
              prev.actionFailure != curr.actionFailure),
      listener: _onStateChanged,
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<EducationBloc>()
              ..add(const EducationRequested());
            await bloc.stream.firstWhere((s) => !s.isLoading);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ...leading,
              ProfileSection(
                title: 'Education',
                showDivider: false,
                count: state.items.isEmpty ? null : state.items.length,
                action: SectionAction(
                  label: 'Add',
                  icon: Icons.add,
                  onPressed: () => _openForm(context),
                ),
                child: _EducationBody(
                  state: state,
                  onEdit: (item) => _openForm(context, item),
                  onDelete: (item) => _confirmDelete(context, item),
                ),
              ),
              ...trailing,
            ],
          ),
        );
      },
    );
  }
}

class _EducationBody extends StatelessWidget {
  const _EducationBody({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final EducationState state;
  final ValueChanged<Education> onEdit;
  final ValueChanged<Education> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final items = state.items;

    if (state.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == EducationStatus.failure && items.isEmpty) {
      return AppErrorView(
        failure: state.failure!,
        onRetry: () =>
            context.read<EducationBloc>().add(const EducationRequested()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Add your degrees and courses so hospitals can check you '
              'meet their requirements.',
              style: muted,
            ),
          ),
        for (var i = 0; i < items.length; i++)
          EducationTile(
            item: items[i],
            highlighted: i == 0,
            showLine: i < items.length - 1,
            deleting: state.isDeleting(items[i]),
            onEdit: () => onEdit(items[i]),
            onDelete: () => onDelete(items[i]),
          ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Tap a card to edit · ⋮ for more',
              textAlign: TextAlign.center,
              style: muted,
            ),
          ),
      ],
    );
  }
}

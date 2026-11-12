import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app/di/injection_container.dart';
import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/language.dart';
import '../bloc/languages_bloc.dart';
import '../models/language_proficiency_ui.dart';
import '../widgets/edit_language_sheet.dart';

/// Languages block on the Overview tab. Creates its own [LanguagesBloc] and
/// opens the add or edit sheet itself, so it needs no arguments.
class LanguagesSection extends StatelessWidget {
  const LanguagesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LanguagesBloc>()..add(const LanguagesRequested()),
      child: const _LanguagesView(),
    );
  }
}

class _LanguagesView extends StatelessWidget {
  const _LanguagesView();

  /// Adds a language, or edits [existing] when given.
  Future<void> _openSheet(BuildContext context, [Language? existing]) async {
    final bloc = context.read<LanguagesBloc>();
    final result = await showEditLanguageSheet(
      context,
      initial: existing,
      taken: bloc.state.names,
    );
    if (result == null) return;

    final proficiency = result.proficiency;
    if (existing == null) {
      if (proficiency != null) {
        bloc.add(LanguageAdded(name: result.name, proficiency: proficiency));
      }
    } else if (proficiency == null) {
      bloc.add(LanguageDeleted(existing));
    } else {
      bloc.add(LanguageUpdated(existing, proficiency));
    }
  }

  void _onStateChanged(BuildContext context, LanguagesState state) {
    final failure = state.actionFailure;
    if (failure != null) {
      AppSnackbar.error(
        title: "Couldn't update your languages",
        message: failure.message,
      );
      return;
    }
    switch (state.change) {
      case LanguageChange.added:
        AppSnackbar.success(title: 'Language added');
      case LanguageChange.updated:
        AppSnackbar.success(title: 'Language updated');
      case LanguageChange.removed:
        AppSnackbar.info(
          title: 'Language removed',
          icon: Icons.delete_outline_rounded,
        );
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LanguagesBloc, LanguagesState>(
      listenWhen: (prev, curr) =>
          (curr.change != null && prev.change != curr.change) ||
          (curr.actionFailure != null &&
              prev.actionFailure != curr.actionFailure),
      listener: _onStateChanged,
      builder: (context, state) {
        final canAdd = !state.isAdding && !state.isLoading;
        return ProfileSection(
          title: 'Languages',
          count: state.items.isEmpty ? null : state.items.length,
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: canAdd ? () => _openSheet(context) : null,
          ),
          child: _LanguagesBody(
            state: state,
            onEdit: (language) => _openSheet(context, language),
          ),
        );
      },
    );
  }
}

class _LanguagesBody extends StatelessWidget {
  const _LanguagesBody({required this.state, required this.onEdit});

  final LanguagesState state;
  final ValueChanged<Language> onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    if (state.isLoading && state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.status == LanguagesStatus.failure && state.items.isEmpty) {
      return Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.failure?.message ?? "Couldn't load your languages.",
              style: muted,
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<LanguagesBloc>().add(const LanguagesRequested()),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.items.isEmpty && !state.isAdding)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Hospitals often filter by language. Add the ones you speak.',
              style: muted,
            ),
          ),
        for (var i = 0; i < state.items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
          _LanguageRow(
            language: state.items[i],
            busy: state.isBusy(state.items[i]),
            onTap: () => onEdit(state.items[i]),
            onRemove: () => context.read<LanguagesBloc>().add(
              LanguageDeleted(state.items[i]),
            ),
          ),
        ],
        if (state.isAdding)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text('Adding…', style: muted),
              ],
            ),
          ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.language,
    required this.busy,
    required this.onTap,
    required this.onRemove,
  });

  final Language language;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: busy ? 0.5 : 1,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const ProfileIconTile(icon: Icons.translate_rounded, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      language.proficiency.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: 40,
                child: busy
                    ? Center(
                        child: SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Remove ${language.name}',
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

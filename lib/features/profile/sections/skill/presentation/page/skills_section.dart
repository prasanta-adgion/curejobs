import 'package:curejobs/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/skill.dart';
import '../bloc/skills_bloc.dart';
import '../widgets/edit_skills_sheet.dart';

/// Skills block on the Overview tab. Reads [SkillsBloc] from the tree.
///
/// Each chip has its own × to remove that skill, with Undo. "Add skill",
/// the empty card and Edit open the sheet for bigger changes.
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  Future<void> _openSheet(BuildContext context) async {
    final bloc = context.read<SkillsBloc>();
    final updated = await showEditSkillsSheet(
      context,
      skills: bloc.state.names,
    );
    if (updated != null) bloc.add(SkillsEdited(updated));
  }

  void _onStateChanged(BuildContext context, SkillsState state) {
    final bloc = context.read<SkillsBloc>();

    final removed = state.removed;
    if (removed != null) {
      AppSnackbar.info(
        title: 'Removed "${removed.skill.name}"',
        icon: Icons.delete_outline_rounded,
        actionLabel: 'Undo',
        onAction: () =>
            bloc.add(SkillRestored(removed.skill.name, index: removed.index)),
      );
    }

    final actionFailure = state.actionFailure;
    if (actionFailure != null) {
      AppSnackbar.error(
        title: "Couldn't update your skills",
        message: actionFailure.message,
      );
    }

    switch (state.saveStatus) {
      case SkillsSaveStatus.saved:
        AppSnackbar.success(title: 'Skills updated');
      case SkillsSaveStatus.failed:
        AppSnackbar.error(
          title: "Couldn't save all your skills",
          message: state.saveFailure?.message ?? 'Try again in a moment.',
        );
      case SkillsSaveStatus.idle || SkillsSaveStatus.saving:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SkillsBloc, SkillsState>(
      listenWhen: (prev, curr) =>
          (curr.removed != null && prev.removed != curr.removed) ||
          (curr.actionFailure != null &&
              prev.actionFailure != curr.actionFailure) ||
          prev.saveStatus != curr.saveStatus,
      listener: _onStateChanged,
      builder: (context, state) {
        final canEdit =
            !state.isSaving && (!state.isLoading || state.items.isNotEmpty);
        final open = canEdit ? () => _openSheet(context) : null;
        final hasSkills = state.items.isNotEmpty;

        return ProfileSection(
          title: 'Skills',
          count: hasSkills ? state.visibleCount : null,
          action: SectionAction(
            label: hasSkills ? 'Edit' : 'Add',
            icon: hasSkills ? Icons.edit_outlined : Icons.add,
            onPressed: open,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkillsBody(state: state, onAdd: open),
              if (state.isSaving)
                const _StatusNote(label: 'Saving…')
              else if (state.removingIds.isNotEmpty)
                const _StatusNote(label: 'Removing…'),
            ],
          ),
        );
      },
    );
  }
}

class _SkillsBody extends StatelessWidget {
  const _SkillsBody({required this.state, required this.onAdd});

  final SkillsState state;
  final VoidCallback? onAdd;

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

    if (state.status == SkillsStatus.failure && state.items.isEmpty) {
      return Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.failure?.message ?? "Couldn't load your skills.",
              style: muted,
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<SkillsBloc>().add(const SkillsRequested()),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (state.items.isEmpty) return _EmptySkills(onTap: onAdd);

    final bloc = context.read<SkillsBloc>();
    // Removing one chip while the sheet saves could clash, so wait.
    final canRemove = !state.isSaving;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final skill in state.items)
          _SkillChip(
            skill: skill,
            removing: state.isRemoving(skill),
            // New skills have no id until the reload after saving.
            onRemove: canRemove && skill.id.isNotEmpty
                ? () => bloc.add(SkillRemoved(skill))
                : null,
          ),
        _AddChip(onTap: onAdd),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.skill,
    required this.removing,
    required this.onRemove,
  });

  final Skill skill;
  final bool removing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: removing ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 36,
              height: 34,
              child: removing
                  ? Center(
                      child: SizedBox.square(
                        dimension: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Remove ${skill.name}',
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      icon: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppIcons.close,
                          size: 12,
                          color: onRemove == null
                              ? scheme.outline
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 16, color: scheme.primary),
              const SizedBox(width: 4),
              Text(
                'Add skill',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySkills extends StatelessWidget {
  const _EmptySkills({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: scheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your key skills',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Hospitals search for skills like ICU care',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusNote extends StatelessWidget {
  const _StatusNote({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          const SizedBox.square(
            dimension: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../sections/language/presentation/page/languages_section.dart';
import '../../sections/skill/presentation/bloc/skills_bloc.dart';
import '../../sections/skill/presentation/page/skills_section.dart';
import '../../sections/skill/presentation/widgets/edit_skills_sheet.dart';
import '../../shared/widgets/profile_section.dart';
import '../models/candidate_profile.dart';
import 'logout_section.dart';
import 'my_applications_section.dart';
import 'next_step_banner.dart';

/// First tab: activity numbers, next step, about, current role, skills and
/// languages. Each section handles its own actions.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.profile});

  /// Sample data for sections that don't have an API yet.
  final CandidateProfile profile;

  /// Opens the skills sheet from the next-step banner.
  Future<void> _addSkills(BuildContext context) async {
    final bloc = context.read<SkillsBloc>();
    final updated = await showEditSkillsSheet(
      context,
      skills: bloc.state.names,
    );
    if (updated != null) bloc.add(SkillsEdited(updated));
  }

  /// Missing profile items, most important first. Only items the user can
  /// actually complete from here are listed; add more as their editors land.
  List<ProfileNextStep> _nextSteps(BuildContext context, SkillsState skills) {
    return [
      // Only once loaded, so a slow request doesn't flash this step.
      if (skills.status == SkillsStatus.success && skills.items.isEmpty)
        ProfileNextStep(
          icon: Icons.psychology_outlined,
          title: 'Add your key skills',
          onPressed: () => _addSkills(context),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SkillsBloc>()..add(const SkillsRequested()),
      child: BlocBuilder<SkillsBloc, SkillsState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.items.isEmpty != curr.items.isEmpty,
        builder: (context, skills) => _buildList(context, skills),
      ),
    );
  }

  Widget _buildList(BuildContext context, SkillsState skills) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = profile.currentRole;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const MyApplicationsSection(counts: ApplicationCounts.sample),
        NextStepBanner(steps: _nextSteps(context, skills)),
        ProfileSection(
          title: 'About',
          child: Text(
            profile.about,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
        ),
        if (current != null)
          ProfileSection(
            title: 'Current role',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProfileIconTile(icon: Icons.local_hospital_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.role,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        current.employer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        current.period,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SkillsSection(),
        const LanguagesSection(),
        const LogoutSection(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../sections/language/presentation/page/languages_section.dart';
import '../../sections/skill/presentation/bloc/skills_bloc.dart';
import '../../sections/skill/presentation/page/skills_section.dart';
import '../../sections/skill/presentation/widgets/edit_skills_sheet.dart';
import 'logout_section.dart';
import 'next_step_banner.dart';
import 'quick_access_section.dart';

/// First tab: next step, quick access (verification, visibility, job alerts,
/// billing), skills and languages. Each section handles its own actions.
class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

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
        builder: (context, skills) {
          final steps = _nextSteps(context, skills);
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (steps.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: NextStepBanner(steps: steps),
                ),
              // No band right under the tabs when there's no next step.
              QuickAccessSection(showDivider: steps.isNotEmpty),
              const SkillsSection(),
              const LanguagesSection(),
              const LogoutSection(),
            ],
          );
        },
      ),
    );
  }
}

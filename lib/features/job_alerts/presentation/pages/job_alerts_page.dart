import 'package:curejobs/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import '../../../specialization/domain/entities/specialization.dart';
import '../../../specialization/presentation/pages/specialization_page.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../bloc/job_alerts_bloc.dart';
import '../widgets/location/location_section.dart';
import '../widgets/role/role_section.dart';
import 'location_search_page.dart';
import '../widgets/range_filter/experience_range_card.dart';
import '../widgets/range_filter/salary_range_card.dart';

/// Job alerts: what jobs to be told about (role, place, type, experience,
/// salary) and how (in-app, email). Edits stay local until Save.
class JobAlertsPage extends StatelessWidget {
  const JobAlertsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const JobAlertsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<JobAlertsBloc>()..add(const JobAlertsRequested()),
      child: const _JobAlertsView(),
    );
  }
}

class _JobAlertsView extends StatelessWidget {
  const _JobAlertsView();

  void _onState(BuildContext context, JobAlertsState state) {
    switch (state.saveStatus) {
      case SaveStatus.success:
        AppSnackbar.success(title: 'Job alerts saved');
      case SaveStatus.failure:
        AppSnackbar.error(
          title: "Couldn't save your job alerts",
          message: state.failure?.message,
          actionLabel: 'Retry',
          onAction: () =>
              context.read<JobAlertsBloc>().add(const JobAlertsSaveRequested()),
        );
      case SaveStatus.idle:
      case SaveStatus.saving:
        break;
    }
  }

  Future<void> _confirmDiscard(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text("Your job alert changes haven't been saved."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if ((discard ?? false) && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return BlocConsumer<JobAlertsBloc, JobAlertsState>(
      listenWhen: (prev, curr) => prev.saveStatus != curr.saveStatus,
      listener: _onState,
      buildWhen: (prev, curr) =>
          prev.status != curr.status || prev.hasChanges != curr.hasChanges,
      builder: (context, state) => PopScope(
        canPop: !state.hasChanges,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmDiscard(context);
        },
        child: Scaffold(
          backgroundColor: scheme.surfaceContainerHighest,
          appBar: AppBar(
            leading: AppBackButton(),
            titleSpacing: 0,
            backgroundColor: AppColors.logoNavy,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Job alerts',
                  style: TextStyle(color: AppColors.white),
                ),
                Text(
                  'Get told when a matching job is posted',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: scheme.outlineVariant),
            ),
          ),
          body: switch (state.status) {
            JobAlertsStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            JobAlertsStatus.failure => AppErrorView(
              failure: state.failure!,
              onRetry: () =>
                  context.read<JobAlertsBloc>().add(const JobAlertsRequested()),
            ),
            JobAlertsStatus.ready => const _Form(),
          },
          bottomNavigationBar: state.status == JobAlertsStatus.ready
              ? const _SaveBar()
              : null,
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form();

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final JobAlertsBloc _bloc = context.read<JobAlertsBloc>();
  late final JobAlertPreferences _start = _bloc.state.draft!;

  JobAlertPreferences get _draft => _bloc.state.draft!;

  void _update(JobAlertPreferences draft) => _bloc.add(JobAlertsChanged(draft));

  Future<void> _pickCategories() async {
    final state = _bloc.state;
    final ids = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => CategoryPage.multi(
          categories: state.categories,
          selectedIds: _draft.categoryIds,
        ),
      ),
    );
    if (ids != null) _bloc.add(JobAlertsCategoriesChanged(ids));
  }

  Future<void> _pickSpecializations() async {
    final state = _bloc.state;
    final names = {for (final c in state.categories) c.id: c.name};
    final items = <Specialization>[];
    final labels = <String, String>{};
    for (final categoryId in _draft.categoryIds) {
      for (final s in state.specializationsByCategory[categoryId] ?? const []) {
        if (labels.containsKey(s.id)) continue;
        items.add(s);
        labels[s.id] = names[categoryId] ?? '';
      }
    }
    final ids = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => SpecializationPage.multi(
          specializations: items,
          groupLabels: _draft.categoryIds.length > 1 ? labels : const {},
          selectedIds: _draft.specializationIds,
        ),
      ),
    );
    if (ids != null) _update(_draft.copyWith(specializationIds: ids));
  }

  Future<void> _searchLocation() async {
    final location = await Navigator.of(context)
        .push(LocationSearchPage.route(added: _draft.locations));
    if (location == null || !mounted) return;
    _addLocation(location);
  }

  void _addLocation(AlertLocation location) {
    final current = _draft.locations;
    if (current.length >= JobAlertPreferences.maxLocations) return;
    if (current.any((l) => l.sameAs(location))) {
      AppSnackbar.info(title: '${location.label} is already added');
      return;
    }
    _update(_draft.copyWith(locations: [...current, location]));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobAlertsBloc, JobAlertsState>(
      buildWhen: (prev, curr) =>
          prev.draft != curr.draft ||
          prev.specializationsByCategory != curr.specializationsByCategory ||
          prev.loadingSpecializations != curr.loadingSpecializations,
      builder: (context, state) {
        final draft = state.draft!;
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 24),
            // Each section on white; the grey page shows as the bands.
            // Material (not ColoredBox) so ListTile ink shows on it.
            children: [
              for (final section in _sections(state, draft))
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: section,
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _sections(JobAlertsState state, JobAlertPreferences draft) => [
    _MasterSwitch(
      draft: draft,
      onChanged: (on) => _update(draft.copyWith(enabled: on)),
    ),
    ProfileSection(
      title: 'Role',
      child: RoleSection(
        state: state,
        onPickCategories: _pickCategories,
        onRemoveCategory: (id) => _bloc.add(
          JobAlertsCategoriesChanged([
            for (final c in draft.categoryIds)
              if (c != id) c,
          ]),
        ),
        onPickSpecializations: _pickSpecializations,
        onRemoveSpecialization: (id) => _update(
          draft.copyWith(
            specializationIds: [
              for (final s in draft.specializationIds)
                if (s != id) s,
            ],
          ),
        ),
      ),
    ),
    ProfileSection(
      title: 'Location',
      child: LocationSection(
        locations: draft.locations,
        onSearch: _searchLocation,
        onAdd: _addLocation,
        onRemove: (location) => _update(
          draft.copyWith(
            locations: [
              for (final l in draft.locations)
                if (l != location) l,
            ],
          ),
        ),
      ),
    ),
    ProfileSection(
      title: 'Job type',
      child: _JobTypeSection(
        selected: draft.employmentTypes,
        onChanged: (types) => _update(draft.copyWith(employmentTypes: types)),
      ),
    ),
    ProfileSection(
      title: 'Experience and salary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Question(
            'Experience and pay',
            'Optional. Leave as is for no limit.',
          ),
          ExperienceRangeCard(
            initialMinMonths: _start.experienceMinMonths,
            initialMaxMonths: _start.experienceMaxMonths,
            onChanged: (min, max) => _update(
              _draft.copyWith(
                experienceMinMonths: min,
                experienceMaxMonths: max,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SalaryRangeCard(
            initialMinMinor: _start.salaryMinMinor,
            initialMaxMinor: _start.salaryMaxMinor,
            onChanged: (min, max) => _update(
              _draft.copyWith(salaryMinMinor: min, salaryMaxMinor: max),
            ),
          ),
        ],
      ),
    ),
    ProfileSection(
      title: 'Send alerts by',
      child: _ChannelsSection(draft: draft, onChanged: _update),
    ),
  ];
}

/// Purple card at the top: are alerts on, and how many filters are set.
class _MasterSwitch extends StatelessWidget {
  const _MasterSwitch({required this.draft, required this.onChanged});

  final JobAlertPreferences draft;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final on = draft.enabled;
    final filters = draft.filtersSet;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Material(
        color: on ? scheme.primaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!on),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: on ? scheme.primary : scheme.outline,
                  child: Icon(
                    on
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    size: 20,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        on ? 'Job alerts are on' : 'Job alerts are paused',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: on ? scheme.onPrimaryContainer : null,
                        ),
                      ),
                      Text(
                        on
                            ? (filters == 0
                                  ? 'No filters · you\'ll hear about every job'
                                  : '$filters of 5 filters set · turn off to pause')
                            : 'Turn on to hear about matching jobs',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: on
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(value: on, onChanged: onChanged),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bold question with a one-line hint under it.
class _Question extends StatelessWidget {
  const _Question(this.question, this.hint);

  final String question;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _JobTypeSection extends StatelessWidget {
  const _JobTypeSection({required this.selected, required this.onChanged});

  final List<AlertEmploymentType> selected;
  final ValueChanged<List<AlertEmploymentType>> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Question(
          'What type of work?',
          'Pick any. Leave empty for all types.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final type in AlertEmploymentType.values)
              FilterChip(
                label: Text(type.label),
                selected: selected.contains(type),
                onSelected: (on) => onChanged([
                  // Keep the enum order so the list compares equal.
                  for (final t in AlertEmploymentType.values)
                    if (t == type ? on : selected.contains(t)) t,
                ]),
                selectedColor: scheme.primaryContainer,
                checkmarkColor: scheme.onPrimaryContainer,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: selected.contains(type)
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChannelsSection extends StatelessWidget {
  const _ChannelsSection({required this.draft, required this.onChanged});

  final JobAlertPreferences draft;
  final ValueChanged<JobAlertPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final none = !draft.inAppEnabled && !draft.emailEnabled;

    Widget tile({
      required IconData icon,
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onToggle,
    }) => SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: scheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onToggle,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        tile(
          icon: Icons.notifications_none_rounded,
          title: 'In-app notifications',
          subtitle: 'On this phone',
          value: draft.inAppEnabled,
          onToggle: (v) => onChanged(draft.copyWith(inAppEnabled: v)),
        ),
        Divider(height: 1, color: scheme.outlineVariant),
        tile(
          icon: Icons.mail_outline_rounded,
          title: 'Email',
          subtitle: 'To your account email',
          value: draft.emailEnabled,
          onToggle: (v) => onChanged(draft.copyWith(emailEnabled: v)),
        ),
        if (none && draft.enabled)
          Text(
            'Turn on at least one, or you won\'t get any alerts.',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
      ],
    );
  }
}

/// "Save preferences" pinned to the bottom, above the keyboard.
class _SaveBar extends StatelessWidget {
  const _SaveBar();

  static bool _valid(JobAlertPreferences? d) {
    if (d == null) return false;
    bool ok(int? min, int? max) => min == null || max == null || min <= max;
    return ok(d.experienceMinMonths, d.experienceMaxMonths) &&
        ok(d.salaryMinMinor, d.salaryMaxMinor);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: BlocBuilder<JobAlertsBloc, JobAlertsState>(
            buildWhen: (prev, curr) =>
                prev.isSaving != curr.isSaving ||
                prev.hasChanges != curr.hasChanges ||
                prev.draft != curr.draft,
            builder: (context, state) {
              final canSave =
                  state.hasChanges && !state.isSaving && _valid(state.draft);
              return SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: canSave
                      ? () {
                          FocusScope.of(context).unfocus();
                          context.read<JobAlertsBloc>().add(
                            const JobAlertsSaveRequested(),
                          );
                        }
                      : null,
                  icon: state.isSaving
                      ? SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: scheme.primary,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    state.isSaving
                        ? 'Saving…'
                        : state.hasChanges
                        ? 'Save preferences'
                        : 'All changes saved',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../profile/shared/widgets/profile_section.dart';
import '../../domain/entities/job_alert_preferences.dart';
import '../bloc/job_alerts_bloc.dart';
import '../widgets/job_alert_sheets.dart';

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

  late final _expMin = TextEditingController(
    text: _start.experienceMinMonths?.toString() ?? '',
  );
  late final _expMax = TextEditingController(
    text: _start.experienceMaxMonths?.toString() ?? '',
  );
  late final _salaryMin = TextEditingController(
    text: _rupees(_start.salaryMinMinor),
  );
  late final _salaryMax = TextEditingController(
    text: _rupees(_start.salaryMaxMinor),
  );

  static String _rupees(int? minor) =>
      minor == null ? '' : (minor ~/ 100).toString();

  static int? _int(String text) => int.tryParse(text.trim());

  @override
  void dispose() {
    _expMin.dispose();
    _expMax.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    super.dispose();
  }

  JobAlertPreferences get _draft => _bloc.state.draft!;

  void _update(JobAlertPreferences draft) => _bloc.add(JobAlertsChanged(draft));

  void _numbersChanged() {
    final salaryMin = _int(_salaryMin.text);
    final salaryMax = _int(_salaryMax.text);
    _update(
      _draft.copyWith(
        experienceMinMonths: _int(_expMin.text),
        experienceMaxMonths: _int(_expMax.text),
        salaryMinMinor: salaryMin == null ? null : salaryMin * 100,
        salaryMaxMinor: salaryMax == null ? null : salaryMax * 100,
      ),
    );
  }

  Future<void> _pickCategories() async {
    final state = _bloc.state;
    final ids = await showMultiSelectSheet(
      context,
      title: 'Choose categories',
      searchHint: 'Search categories, e.g. Nursing',
      options: [
        for (final c in state.categories) SheetOption(id: c.id, label: c.name),
      ],
      selected: _draft.categoryIds,
    );
    if (ids != null) _bloc.add(JobAlertsCategoriesChanged(ids));
  }

  Future<void> _pickSpecializations() async {
    final state = _bloc.state;
    final names = {for (final c in state.categories) c.id: c.name};
    final seen = <String>{};
    final ids = await showMultiSelectSheet(
      context,
      title: 'Choose specializations',
      searchHint: 'Search specializations, e.g. ICU',
      options: [
        for (final categoryId in _draft.categoryIds)
          for (final s
              in state.specializationsByCategory[categoryId] ?? const [])
            if (seen.add(s.id))
              SheetOption(id: s.id, label: s.name, subtitle: names[categoryId]),
      ],
      selected: _draft.specializationIds,
    );
    if (ids != null) _update(_draft.copyWith(specializationIds: ids));
  }

  Future<void> _addLocation({required bool wholeState}) async {
    final location = await showLocationSheet(context, wholeState: wholeState);
    if (location == null || !mounted) return;
    final current = _draft.locations;
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
            children: [
              for (final section in _sections(state, draft))
                ColoredBox(
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
      child: _RoleSection(
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
      child: _LocationSection(
        locations: draft.locations,
        onAddCity: () => _addLocation(wholeState: false),
        onAddState: () => _addLocation(wholeState: true),
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
      child: _LimitsSection(
        draft: draft,
        expMin: _expMin,
        expMax: _expMax,
        salaryMin: _salaryMin,
        salaryMax: _salaryMax,
        onChanged: _numbersChanged,
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

class _Label extends StatelessWidget {
  const _Label(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (optional)
              TextSpan(
                text: '  (optional)',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// A chosen item: purple chip with an ✕ to remove it.
class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.label, required this.onRemove, this.icon});

  final String label;
  final IconData? icon;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InputChip(
      label: Text(label),
      avatar: icon == null
          ? null
          : Icon(icon, size: 16, color: scheme.onPrimaryContainer),
      onDeleted: onRemove,
      deleteButtonTooltipMessage: 'Remove $label',
      backgroundColor: scheme.primaryContainer,
      side: BorderSide.none,
      labelStyle: TextStyle(color: scheme.onPrimaryContainer),
      deleteIconColor: scheme.onPrimaryContainer,
      shape: const StadiumBorder(),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// "+ Add" chip with a dashed border that opens a picker.
class _AddChip extends StatelessWidget {
  const _AddChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _DashedButton(
      label: label,
      icon: Icons.add,
      onTap: onTap,
      radius: 999,
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

/// Text and icon inside a dashed outline. Greyed out when [onTap] is null.
class _DashedButton extends StatelessWidget {
  const _DashedButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.radius,
    required this.height,
    required this.padding,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final double radius;
  final double height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = onTap != null ? scheme.primary : scheme.outline;
    final shape = BorderRadius.circular(radius);

    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: shape,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape,
        child: CustomPaint(
          painter: _DashedBorderPainter(color: color, radius: radius),
          child: Container(
            height: height,
            padding: padding,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final r = radius.clamp(0, size.height / 2).toDouble();
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.6),
          Radius.circular(r),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

class _RoleSection extends StatelessWidget {
  const _RoleSection({
    required this.state,
    required this.onPickCategories,
    required this.onRemoveCategory,
    required this.onPickSpecializations,
    required this.onRemoveSpecialization,
  });

  final JobAlertsState state;
  final VoidCallback onPickCategories;
  final ValueChanged<String> onRemoveCategory;
  final VoidCallback onPickSpecializations;
  final ValueChanged<String> onRemoveSpecialization;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = state.selectedCategories;
    final specializations = state.selectedSpecializations;
    final hasCategories = categories.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Question(
          'What kind of jobs?',
          'Leave empty to hear about every category.',
        ),
        const _Label('Categories'),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in categories)
              _SelectedChip(
                label: c.name,
                onRemove: () => onRemoveCategory(c.id),
              ),
            _AddChip(
              label: hasCategories ? 'Add more' : 'Add category',
              onTap: onPickCategories,
            ),
          ],
        ),
        const _Label('Specializations', optional: true),
        if (!hasCategories)
          Text(
            'Pick a category first to narrow it down.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else if (state.loadingSpecializations && specializations.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          )
        else
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in specializations)
                _SelectedChip(
                  label: s.name,
                  onRemove: () => onRemoveSpecialization(s.id),
                ),
              _AddChip(
                label: specializations.isEmpty
                    ? 'Add specialization'
                    : 'Add more',
                onTap: state.availableSpecializations.isEmpty
                    ? null
                    : onPickSpecializations,
              ),
            ],
          ),
      ],
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({
    required this.locations,
    required this.onAddCity,
    required this.onAddState,
    required this.onRemove,
  });

  final List<AlertLocation> locations;
  final VoidCallback onAddCity;
  final VoidCallback onAddState;
  final ValueChanged<AlertLocation> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final full = locations.length >= JobAlertPreferences.maxLocations;

    Widget addButton(String label, IconData icon, VoidCallback onTap) =>
        Expanded(
          child: _DashedButton(
            label: label,
            icon: icon,
            onTap: full ? null : onTap,
            radius: 10,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Question(
          'Where do you want to work?',
          'Leave empty to hear about jobs anywhere.',
        ),
        if (locations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final l in locations)
                _SelectedChip(
                  label: l.label,
                  icon: l.isWholeState
                      ? Icons.map_outlined
                      : Icons.location_on_outlined,
                  onRemove: () => onRemove(l),
                ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            addButton('Add city', Icons.location_on_outlined, onAddCity),
            const SizedBox(width: 8),
            addButton('Add whole state', Icons.map_outlined, onAddState),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          full
              ? 'You\'ve reached ${JobAlertPreferences.maxLocations} places. '
                    'Remove one to add another.'
              : '${locations.length} of ${JobAlertPreferences.maxLocations} places',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
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

class _LimitsSection extends StatelessWidget {
  const _LimitsSection({
    required this.draft,
    required this.expMin,
    required this.expMax,
    required this.salaryMin,
    required this.salaryMax,
    required this.onChanged,
  });

  final JobAlertPreferences draft;
  final TextEditingController expMin;
  final TextEditingController expMax;
  final TextEditingController salaryMin;
  final TextEditingController salaryMax;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final expError = _rangeError(
      draft.experienceMinMonths,
      draft.experienceMaxMonths,
    );
    final salaryError = _rangeError(draft.salaryMinMinor, draft.salaryMaxMinor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Question(
          'Experience and pay',
          'Optional. Leave blank for no limit.',
        ),
        const _Label('Experience (in months)'),
        _Range(
          min: expMin,
          max: expMax,
          suffix: 'months',
          minHint: '0',
          error: expError,
          onChanged: onChanged,
        ),
        const _Label('Monthly salary'),
        _Range(
          min: salaryMin,
          max: salaryMax,
          prefix: '₹ ',
          minHint: 'Any',
          error: salaryError,
          onChanged: onChanged,
        ),
      ],
    );
  }

  static String? _rangeError(int? min, int? max) =>
      min != null && max != null && min > max
      ? 'The first number should be smaller than the second.'
      : null;
}

/// "From – to" pair of number fields.
class _Range extends StatelessWidget {
  const _Range({
    required this.min,
    required this.max,
    required this.onChanged,
    required this.minHint,
    this.prefix,
    this.suffix,
    this.error,
  });

  final TextEditingController min;
  final TextEditingController max;
  final VoidCallback onChanged;
  final String minHint;
  final String? prefix;
  final String? suffix;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget field(TextEditingController c, String hint) => Expanded(
      child: TextField(
        controller: c,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          suffixText: suffix,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            field(min, minHint),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'to',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            field(max, 'No limit'),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
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

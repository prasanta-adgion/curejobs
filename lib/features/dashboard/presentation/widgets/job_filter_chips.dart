import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../models/job_filters.dart';
import 'filter_options_sheet.dart';

/// Row of dropdown pills: job type, experience and date posted.
class JobFilterChips extends StatelessWidget {
  const JobFilterChips({
    super.key,
    required this.jobTypes,
    required this.experience,
    required this.datePosted,
    required this.onJobTypesChanged,
    required this.onExperienceChanged,
    required this.onDatePostedChanged,
  });

  final Set<JobType> jobTypes;
  final ExperienceLevel? experience;
  final DatePosted? datePosted;
  final ValueChanged<Set<JobType>> onJobTypesChanged;
  final ValueChanged<ExperienceLevel?> onExperienceChanged;
  final ValueChanged<DatePosted?> onDatePostedChanged;

  String get _jobTypeLabel {
    if (jobTypes.isEmpty) return 'Job type';
    final first = JobType.values.firstWhere(jobTypes.contains).label;
    return jobTypes.length == 1 ? first : '$first +${jobTypes.length - 1}';
  }

  Future<void> _pickJobTypes(BuildContext context) async {
    final result = await FilterOptionsSheet.show<JobType>(
      context,
      title: 'Job type',
      options: JobType.values,
      labelOf: (type) => type.label,
      selected: jobTypes,
      multiSelect: true,
    );
    if (result != null) onJobTypesChanged(result);
  }

  Future<void> _pickExperience(BuildContext context) async {
    final result = await FilterOptionsSheet.show<ExperienceLevel>(
      context,
      title: 'Experience',
      options: ExperienceLevel.values,
      labelOf: (level) => level.label,
      selected: {?experience},
    );
    if (result != null) onExperienceChanged(result.firstOrNull);
  }

  Future<void> _pickDatePosted(BuildContext context) async {
    final result = await FilterOptionsSheet.show<DatePosted>(
      context,
      title: 'Date posted',
      options: DatePosted.values,
      labelOf: (date) => date.label,
      selected: {?datePosted},
    );
    if (result != null) onDatePostedChanged(result.firstOrNull);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _DropdownPill(
            label: _jobTypeLabel,
            active: jobTypes.isNotEmpty,
            onTap: () => _pickJobTypes(context),
          ),
          const SizedBox(width: 8),
          _DropdownPill(
            label: experience?.label ?? 'Experience',
            active: experience != null,
            onTap: () => _pickExperience(context),
          ),
          const SizedBox(width: 8),
          _DropdownPill(
            label: datePosted?.label ?? 'Date posted',
            active: datePosted != null,
            onTap: () => _pickDatePosted(context),
          ),
        ],
      ),
    );
  }
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.pill);
    final foreground = active ? scheme.onPrimaryContainer : scheme.onSurface;

    return Material(
      color: active ? scheme.primaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: active ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 10, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

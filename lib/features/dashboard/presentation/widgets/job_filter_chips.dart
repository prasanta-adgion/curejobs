import 'package:flutter/material.dart';

import '../../../../app/theme/app_radius.dart';
import '../models/job_filters.dart';
import 'filter_options_sheet.dart';

/// Row of filter tags: job type, experience and date posted. A selected
/// filter turns violet and shows an × that clears it.
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

  bool get _hasActive =>
      jobTypes.isNotEmpty || experience != null || datePosted != null;

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

  void _clearAll() {
    onJobTypesChanged({});
    onExperienceChanged(null);
    onDatePostedChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterTag(
            label: _jobTypeLabel,
            active: jobTypes.isNotEmpty,
            onTap: () => _pickJobTypes(context),
            onClear: () => onJobTypesChanged({}),
          ),
          const SizedBox(width: 8),
          _FilterTag(
            label: experience?.label ?? 'Experience',
            active: experience != null,
            onTap: () => _pickExperience(context),
            onClear: () => onExperienceChanged(null),
          ),
          const SizedBox(width: 8),
          _FilterTag(
            label: datePosted?.label ?? 'Date posted',
            active: datePosted != null,
            onTap: () => _pickDatePosted(context),
            onClear: () => onDatePostedChanged(null),
          ),
          if (_hasActive) ...[
            const SizedBox(width: 4),
            TextButton(onPressed: _clearAll, child: const Text('Clear all')),
          ],
        ],
      ),
    );
  }
}

class _FilterTag extends StatelessWidget {
  const _FilterTag({
    required this.label,
    required this.active,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.small);
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
          padding: EdgeInsets.fromLTRB(12, 8, active ? 4 : 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(color: foreground),
              ),
              const SizedBox(width: 2),
              if (active)
                Semantics(
                  button: true,
                  label: 'Clear $label',
                  child: InkResponse(
                    onTap: onClear,
                    radius: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: foreground,
                      ),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: foreground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

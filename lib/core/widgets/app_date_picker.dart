import 'package:flutter/material.dart';

import '../utils/date_time_utils.dart';

/// A one-tap date in the picker, like "Today" or "+2 yrs".
class AppDateShortcut {
  const AppDateShortcut(this.label, this.date);

  final String label;
  final DateTime date;
}

/// App-wide date picker dialog. Uses the theme's colour scheme, so it
/// follows light and dark mode.
///
/// - [pickDate] picks a day, with a calendar and a year/month jump.
/// - [pickMonth] picks a month and year (the day is always 1).
/// - [pickYear] picks a year only.
///
/// Dates before [first] or after [last] are greyed out. All return null
/// when the user cancels.
abstract final class AppDatePicker {
  static Future<DateTime?> pickDate(
    BuildContext context, {
    required String title,
    DateTime? initial,
    DateTime? first,
    DateTime? last,
    List<AppDateShortcut> shortcuts = const [],
  }) {
    return _show(
      context,
      _PickerConfig(
        precision: _Precision.day,
        title: title,
        initial: initial,
        first: first,
        last: last,
        shortcuts: shortcuts,
      ),
    );
  }

  static Future<DateTime?> pickMonth(
    BuildContext context, {
    required String title,
    DateTime? initial,
    DateTime? first,
    DateTime? last,
  }) {
    return _show(
      context,
      _PickerConfig(
        precision: _Precision.month,
        title: title,
        initial: initial,
        first: first,
        last: last,
      ),
    );
  }

  static Future<int?> pickYear(
    BuildContext context, {
    required String title,
    int? initial,
    int? first,
    int? last,
  }) async {
    final picked = await _show(
      context,
      _PickerConfig(
        precision: _Precision.year,
        title: title,
        initial: initial == null ? null : DateTime(initial),
        first: first == null ? null : DateTime(first),
        last: last == null ? null : DateTime(last, 12, 31),
      ),
    );
    return picked?.year;
  }

  static Future<DateTime?> _show(BuildContext context, _PickerConfig config) {
    FocusScope.of(context).unfocus();
    return showDialog<DateTime>(
      context: context,
      builder: (_) => _AppDatePickerDialog(config: config),
    );
  }
}

enum _Precision { day, month, year }

enum _View { days, years, months }

class _PickerConfig {
  _PickerConfig({
    required this.precision,
    required this.title,
    DateTime? initial,
    DateTime? first,
    DateTime? last,
    this.shortcuts = const [],
  }) : first = DateTimeUtils.dateOnly(first ?? DateTime(1950)),
       last = DateTimeUtils.dateOnly(
         last ?? DateTime(DateTime.now().year + 30, 12, 31),
       ),
       initial = initial == null ? null : DateTimeUtils.dateOnly(initial);

  final _Precision precision;
  final String title;
  final DateTime? initial;
  final DateTime first;
  final DateTime last;
  final List<AppDateShortcut> shortcuts;

  bool dayAllowed(DateTime d) => !d.isBefore(first) && !d.isAfter(last);

  bool monthAllowed(int year, int month) =>
      !DateTime(year, month + 1, 0).isBefore(first) &&
      !DateTime(year, month).isAfter(last);

  bool yearAllowed(int year) => year >= first.year && year <= last.year;
}

class _AppDatePickerDialog extends StatefulWidget {
  const _AppDatePickerDialog({required this.config});

  final _PickerConfig config;

  @override
  State<_AppDatePickerDialog> createState() => _AppDatePickerDialogState();
}

class _AppDatePickerDialogState extends State<_AppDatePickerDialog> {
  late final _PickerConfig _c = widget.config;

  /// What's chosen so far (null until the user picks).
  late final _selected = ValueNotifier<DateTime?>(_c.initial);

  /// The month shown in the calendar.
  late final _visible = ValueNotifier<DateTime>(_startMonth());

  late final _view = ValueNotifier<_View>(switch (_c.precision) {
    _Precision.day => _View.days,
    _Precision.month || _Precision.year => _View.years,
  });

  @override
  void dispose() {
    _selected.dispose();
    _visible.dispose();
    _view.dispose();
    super.dispose();
  }

  DateTime _startMonth() {
    var d = _c.initial ?? DateTimeUtils.today;
    if (d.isBefore(_c.first)) d = _c.first;
    if (d.isAfter(_c.last)) d = _c.last;
    return DateTime(d.year, d.month);
  }

  void _pickYear(int year) {
    if (_c.precision == _Precision.year) {
      Navigator.of(context).pop(DateTime(year));
      return;
    }
    _visible.value = DateTime(year, _visible.value.month);
    _view.value = _View.months;
  }

  void _pickMonth(int month) {
    final year = _visible.value.year;
    if (_c.precision == _Precision.month) {
      Navigator.of(context).pop(DateTime(year, month));
      return;
    }
    _visible.value = DateTime(year, month);
    _view.value = _View.days;
  }

  void _shiftMonth(int by) {
    final v = _visible.value;
    _visible.value = DateTime(v.year, v.month + by);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: ListenableBuilder(
          listenable: Listenable.merge([_selected, _visible, _view]),
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                title: _c.title,
                precision: _c.precision,
                selected: _selected.value,
                view: _view.value,
              ),
              Divider(height: 1, color: scheme.outlineVariant),
              switch (_view.value) {
                _View.days => _DaysView(
                  config: _c,
                  visible: _visible.value,
                  selected: _selected.value,
                  onSelect: (d) => _selected.value = d,
                  onShift: _shiftMonth,
                  onOpenYears: () => _view.value = _View.years,
                ),
                _View.years => _YearsView(
                  config: _c,
                  selectedYear: (_selected.value ?? _visible.value).year,
                  onPick: _pickYear,
                ),
                _View.months => _MonthsView(
                  config: _c,
                  year: _visible.value.year,
                  selected: _selected.value,
                  onPick: _pickMonth,
                  onBack: () => _view.value = _View.years,
                ),
              },
              if (_view.value == _View.days && _c.shortcuts.isNotEmpty)
                _Shortcuts(
                  config: _c,
                  selected: _selected.value,
                  onPick: (d) {
                    _selected.value = d;
                    _visible.value = DateTime(d.year, d.month);
                  },
                ),
              _Footer(
                // Year and month pickers close on tap, so only the day
                // view needs Select.
                onSelect:
                    _c.precision == _Precision.day && _selected.value != null
                    ? () => Navigator.of(context).pop(_selected.value)
                    : null,
                showSelect: _c.precision == _Precision.day,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.precision,
    required this.selected,
    required this.view,
  });

  final String title;
  final _Precision precision;
  final DateTime? selected;
  final _View view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = selected;

    final String headline;
    if (precision == _Precision.year) {
      headline = 'Pick a year';
    } else if (view == _View.years) {
      headline = s == null ? 'Pick a year' : '${s.year}';
    } else if (s == null) {
      headline = precision == _Precision.month ? 'Pick a month' : 'Pick a date';
    } else {
      headline = precision == _Precision.month
          ? DateTimeUtils.monthYear(s)
          : DateTimeUtils.day(s);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  headline,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: s == null && precision != _Precision.year
                        ? scheme.outline
                        : scheme.onSurface,
                  ),
                ),
              ),
              if (s != null &&
                  precision == _Precision.day &&
                  view == _View.days) ...[
                const SizedBox(width: 8),
                Text(
                  DateTimeUtils.weekday(s),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          if (s != null && precision == _Precision.day && view == _View.days)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateTimeUtils.relative(s),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DaysView extends StatelessWidget {
  const _DaysView({
    required this.config,
    required this.visible,
    required this.selected,
    required this.onSelect,
    required this.onShift,
    required this.onOpenYears,
  });

  static const _cell = 40.0;

  final _PickerConfig config;
  final DateTime visible;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final ValueChanged<int> onShift;
  final VoidCallback onOpenYears;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = DateTimeUtils.today;
    final year = visible.year;
    final month = visible.month;
    final days = DateTimeUtils.daysInMonth(year, month);
    final blanks = DateTime(year, month).weekday - 1;
    final canBack = !DateTime(
      year,
      month,
    ).isBefore(DateTime(config.first.year, config.first.month + 1));
    final canNext = DateTime(
      year,
      month + 1,
    ).isBefore(DateTime(config.last.year, config.last.month + 1));

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onOpenYears,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${DateTimeUtils.fullMonths[month - 1]} $year',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: scheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous month',
                onTap: canBack ? () => onShift(-1) : null,
              ),
              const SizedBox(width: 6),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next month',
                onTap: canNext ? () => onShift(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            childAspectRatio: 1,
            children: [
              for (var i = 0; i < blanks; i++) const SizedBox.shrink(),
              for (var day = 1; day <= days; day++)
                _DayCell(
                  date: DateTime(year, month, day),
                  size: _cell,
                  isSelected:
                      selected != null &&
                      DateTimeUtils.isSameDay(
                        selected!,
                        DateTime(year, month, day),
                      ),
                  isToday: DateTimeUtils.isSameDay(
                    today,
                    DateTime(year, month, day),
                  ),
                  enabled: config.dayAllowed(DateTime(year, month, day)),
                  onTap: onSelect,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.size,
    required this.isSelected,
    required this.isToday,
    required this.enabled,
    required this.onTap,
  });

  final DateTime date;
  final double size;
  final bool isSelected;
  final bool isToday;
  final bool enabled;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final weekend = date.weekday >= DateTime.saturday;

    final Color textColor;
    if (isSelected) {
      textColor = scheme.onPrimary;
    } else if (!enabled) {
      textColor = scheme.outline.withValues(alpha: 0.4);
    } else if (isToday) {
      textColor = scheme.primary;
    } else if (weekend) {
      textColor = scheme.onSurfaceVariant;
    } else {
      textColor = scheme.onSurface;
    }

    return Center(
      child: Semantics(
        button: true,
        selected: isSelected,
        enabled: enabled,
        label: DateTimeUtils.day(date),
        child: InkResponse(
          onTap: enabled ? () => onTap(date) : null,
          radius: size / 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? scheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: scheme.primary.withValues(alpha: 0.6))
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 34,
            child: Icon(
              icon,
              size: 20,
              color: enabled
                  ? scheme.onSurfaceVariant
                  : scheme.outline.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _YearsView extends StatelessWidget {
  const _YearsView({
    required this.config,
    required this.selectedYear,
    required this.onPick,
  });

  static const _rowHeight = 46.0;

  final _PickerConfig config;
  final int selectedYear;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final years = [
      for (var y = config.first.year; y <= config.last.year; y++) y,
    ];
    final thisYear = DateTime.now().year;
    final index = years.indexOf(selectedYear).clamp(0, years.length - 1);
    final controller = ScrollController(
      initialScrollOffset:
          ((index ~/ 4) - 2).clamp(0, years.length) * _rowHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: _rowHeight * 5,
          child: GridView.builder(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            itemCount: years.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: 40,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemBuilder: (context, i) {
              final year = years[i];
              return _GridChoice(
                label: '$year',
                selected: year == selectedYear,
                current: year == thisYear,
                enabled: config.yearAllowed(year),
                onTap: () => onPick(year),
              );
            },
          ),
        ),
        const _Legend(),
      ],
    );
  }
}

class _MonthsView extends StatelessWidget {
  const _MonthsView({
    required this.config,
    required this.year,
    required this.selected,
    required this.onPick,
    required this.onBack,
  });

  final _PickerConfig config;
  final int year;
  final DateTime? selected;
  final ValueChanged<int> onPick;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: scheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
              icon: Icon(Icons.chevron_left_rounded, color: scheme.primary),
              label: Text(
                '$year',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.9,
            children: [
              for (var m = 1; m <= 12; m++)
                _GridChoice(
                  label: DateTimeUtils.months[m - 1],
                  selected:
                      selected != null &&
                      selected!.year == year &&
                      selected!.month == m,
                  current: now.year == year && now.month == m,
                  enabled: config.monthAllowed(year, m),
                  onTap: () => onPick(m),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

/// A year or month tile: solid purple when selected, outlined purple for
/// the current one, greyed out when not allowed.
class _GridChoice extends StatelessWidget {
  const _GridChoice({
    required this.label,
    required this.selected,
    required this.current,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool current;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final Color border;
    if (selected || !enabled) {
      border = Colors.transparent;
    } else if (current) {
      border = scheme.primary.withValues(alpha: 0.6);
    } else {
      border = scheme.outlineVariant;
    }

    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border, width: current && !selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: selected || current
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: selected
                  ? scheme.onPrimary
                  : !enabled
                  ? scheme.outline.withValues(alpha: 0.4)
                  : current
                  ? scheme.primary
                  : scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.6),
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'This year · Greyed out: not allowed',
            style: theme.textTheme.labelSmall?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}

class _Shortcuts extends StatelessWidget {
  const _Shortcuts({
    required this.config,
    required this.selected,
    required this.onPick,
  });

  final _PickerConfig config;
  final DateTime? selected;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final s in config.shortcuts)
            Builder(
              builder: (context) {
                final date = DateTimeUtils.dateOnly(s.date);
                final enabled = config.dayAllowed(date);
                final active =
                    selected != null &&
                    DateTimeUtils.isSameDay(selected!, date);
                return Material(
                  color: active
                      ? scheme.primaryContainer.withValues(alpha: 0.6)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: active ? scheme.primary : scheme.outlineVariant,
                    ),
                  ),
                  child: InkWell(
                    onTap: enabled ? () => onPick(date) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Text(
                        s.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: !enabled
                              ? scheme.outline.withValues(alpha: 0.5)
                              : active
                              ? scheme.primary
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onSelect, required this.showSelect});

  final VoidCallback? onSelect;
  final bool showSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const height = Size.fromHeight(46);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: height,
                  shape: shape,
                ),
                child: const Text('Cancel'),
              ),
            ),
            if (showSelect) ...[
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    minimumSize: height,
                    shape: shape,
                  ),
                  child: const Text('Select'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

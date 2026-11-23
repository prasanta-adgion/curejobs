import 'package:flutter/material.dart';

import 'range_filter_parts.dart';

/// Experience filter in whole years: summary, two-handle slider, quick
/// picks and − / + boxes. Reports months (years × 12); null means no limit.
class ExperienceRangeCard extends StatefulWidget {
  const ExperienceRangeCard({
    super.key,
    this.initialMinMonths,
    this.initialMaxMonths,
    required this.onChanged,
  });

  final int? initialMinMonths;
  final int? initialMaxMonths;
  final void Function(int? minMonths, int? maxMonths) onChanged;

  @override
  State<ExperienceRangeCard> createState() => _ExperienceRangeCardState();
}

class _ExperienceRangeCardState extends State<ExperienceRangeCard> {
  /// The slider's last stop; a maximum here means "no upper limit".
  static const _top = 20;

  static const _presets = [
    RangePreset('Fresher', RangeValue(null, 0)),
    RangePreset('0–2 yrs', RangeValue(null, 2)),
    RangePreset('2–5 yrs', RangeValue(2, 5)),
    RangePreset('5–10 yrs', RangeValue(5, 10)),
    RangePreset('10+ yrs', RangeValue(10, null)),
  ];

  /// Kept in years.
  late final _years = ValueNotifier<RangeValue>(
    _normalize(
      RangeValue(
        _toYears(widget.initialMinMonths),
        _toYears(widget.initialMaxMonths),
      ),
    ),
  );

  static int? _toYears(int? months) =>
      months == null ? null : (months / 12).round();

  /// 0 as a minimum and [_top] as a maximum both mean "no limit".
  static RangeValue _normalize(RangeValue v) {
    final min = v.min == null || v.min! <= 0 ? null : v.min!.clamp(0, _top);
    final max = v.max == null || v.max! >= _top ? null : v.max!.clamp(0, _top);
    return RangeValue(min, max);
  }

  void _set(RangeValue next) {
    final v = _normalize(next);
    if (v == _years.value) return;
    _years.value = v;
    widget.onChanged(
      v.min == null ? null : v.min! * 12,
      v.max == null ? null : v.max! * 12,
    );
  }

  @override
  void dispose() {
    _years.dispose();
    super.dispose();
  }

  static String _yrs(int n) => n == 1 ? '1 year' : '$n years';

  static String _summary(RangeValue v) {
    final min = v.min ?? 0;
    if (v.max == null)
      return min == 0 ? 'any experience' : 'at least ${_yrs(min)}';
    if (v.max == 0) return 'freshers (no experience)';
    if (min == 0) return 'up to ${_yrs(v.max!)}';
    if (min == v.max) return 'exactly ${_yrs(min)}';
    return '$min to ${_yrs(v.max!)}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RangeValue>(
      valueListenable: _years,
      builder: (context, v, _) {
        final min = v.min ?? 0;
        final max = v.max ?? _top;
        return RangeFilterCard(
          children: [
            RangeCardHeader(
              icon: Icons.work_outline_rounded,
              title: 'Experience',
              onClear: v.isAny ? null : () => _set(RangeValue.any),
            ),
            RangeSummary(lead: 'Jobs asking for ', value: _summary(v)),
            RangeSliderRow(
              values: RangeValues(min.toDouble(), max.toDouble()),
              max: _top.toDouble(),
              divisions: _top,
              labels: const ['Fresher', '10 yrs', '$_top+ yrs'],
              onChanged: (r) =>
                  _set(RangeValue(r.start.round(), r.end.round())),
            ),
            RangePresetChips(presets: _presets, selected: v, onSelected: _set),
            MinMaxRow(
              min: StepperBox(
                label: 'Minimum',
                value: min == 0 ? 'Fresher' : '$min yrs',
                onMinus: min > 0
                    ? () => _set(RangeValue(min - 1, v.max))
                    : null,
                onPlus: min < max
                    ? () => _set(RangeValue(min + 1, v.max))
                    : null,
              ),
              max: StepperBox(
                label: 'Maximum',
                value: v.max == null ? 'No limit' : '${v.max} yrs',
                onMinus: max > min
                    ? () => _set(RangeValue(v.min, max - 1))
                    : null,
                onPlus: v.max != null
                    ? () => _set(RangeValue(v.min, max + 1))
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

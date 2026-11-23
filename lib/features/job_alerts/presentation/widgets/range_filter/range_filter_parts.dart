import 'package:flutter/material.dart';

/// A "from – to" choice. `null` on either side means no limit.
@immutable
class RangeValue {
  const RangeValue(this.min, this.max);

  static const any = RangeValue(null, null);

  final int? min;
  final int? max;

  bool get isAny => min == null && max == null;

  /// True when both ends are set and the first is bigger.
  bool get isInverted => min != null && max != null && min! > max!;

  @override
  bool operator ==(Object other) =>
      other is RangeValue && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// One quick-pick chip, like "2–5 yrs".
class RangePreset {
  const RangePreset(this.label, this.value);

  final String label;
  final RangeValue value;
}

/// Bordered card that holds one range filter.
class RangeFilterCard extends StatelessWidget {
  const RangeFilterCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Icon, title, optional trailing control and a "Clear" link.
class RangeCardHeader extends StatelessWidget {
  const RangeCardHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onClear,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  /// Hidden when null (nothing to clear).
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

/// "Jobs asking for **2 to 5 years**".
class RangeSummary extends StatelessWidget {
  const RangeSummary({super.key, required this.lead, required this.value});

  final String lead;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Text.rich(
      TextSpan(
        text: lead,
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

/// Two-handle slider with three labels under it (start, middle, end).
class RangeSliderRow extends StatelessWidget {
  const RangeSliderRow({
    super.key,
    required this.values,
    required this.max,
    required this.divisions,
    required this.labels,
    required this.onChanged,
  });

  final RangeValues values;
  final double max;
  final int divisions;

  /// Exactly three: start, middle, end.
  final List<String> labels;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 6),
            child: RangeSlider(
              values: RangeValues(
                values.start.clamp(0, max),
                values.end.clamp(0, max),
              ),
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (final l in labels) Text(l, style: style)],
        ),
      ],
    );
  }
}

/// Horizontal row of quick-pick chips; the one matching [selected] is on.
class RangePresetChips extends StatelessWidget {
  const RangePresetChips({
    super.key,
    required this.presets,
    required this.selected,
    required this.onSelected,
  });

  final List<RangePreset> presets;
  final RangeValue selected;
  final ValueChanged<RangeValue> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          for (final p in presets)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.label),
                selected: p.value == selected,
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                onSelected: (_) => onSelected(p.value),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Minimum – Maximum" pair of boxes with a dash between.
class MinMaxRow extends StatelessWidget {
  const MinMaxRow({super.key, required this.min, required this.max});

  final Widget min;
  final Widget max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: min),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '–',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: max),
      ],
    );
  }
}

/// Labelled box with − and + buttons around a value.
class StepperBox extends StatelessWidget {
  const StepperBox({
    super.key,
    required this.label,
    required this.value,
    this.onMinus,
    this.onPlus,
  });

  final String label;
  final String value;

  /// Disabled when null.
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget button(IconData icon, String tip, VoidCallback? onTap) => IconButton(
      tooltip: tip,
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      padding: EdgeInsets.zero,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              button(Icons.remove_rounded, 'Less', onMinus),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              button(Icons.add_rounded, 'More', onPlus),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small red line under a range when it can't be saved.
class RangeError extends StatelessWidget {
  const RangeError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

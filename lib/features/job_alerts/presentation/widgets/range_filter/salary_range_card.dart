import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'range_filter_parts.dart';

enum SalaryPeriod {
  monthly('Monthly', 'a month', 1),
  yearly('Yearly', 'a year', 12);

  const SalaryPeriod(this.label, this.per, this.factor);

  final String label;
  final String per;
  final int factor;
}

/// Salary filter. Always stored per month; the Monthly / Yearly switch only
/// changes what the user sees and types. Reports paise (rupees × 100); null
/// means no limit.
class SalaryRangeCard extends StatefulWidget {
  const SalaryRangeCard({
    super.key,
    this.initialMinMinor,
    this.initialMaxMinor,
    required this.onChanged,
  });

  final int? initialMinMinor;
  final int? initialMaxMinor;
  final void Function(int? minMinor, int? maxMinor) onChanged;

  @override
  State<SalaryRangeCard> createState() => _SalaryRangeCardState();
}

class _SalaryRangeCardState extends State<SalaryRangeCard> {
  /// Monthly rupees at the slider's end; a maximum here means "no limit".
  static const _top = 200000;
  static const _step = 5000;

  /// Monthly rupees.
  late final _monthly = ValueNotifier<RangeValue>(
    RangeValue(
      _rupees(widget.initialMinMinor),
      _rupees(widget.initialMaxMinor),
    ),
  );
  final _period = ValueNotifier<SalaryPeriod>(SalaryPeriod.monthly);
  final _minField = TextEditingController();
  final _maxField = TextEditingController();

  static int? _rupees(int? minor) => minor == null ? null : minor ~/ 100;

  @override
  void initState() {
    super.initState();
    _syncFields();
    _period.addListener(_syncFields);
  }

  @override
  void dispose() {
    _period.removeListener(_syncFields);
    _monthly.dispose();
    _period.dispose();
    _minField.dispose();
    _maxField.dispose();
    super.dispose();
  }

  int get _factor => _period.value.factor;

  /// Writes the current value into the boxes (not used while typing).
  void _syncFields() {
    final v = _monthly.value;
    _minField.text = v.min == null ? '' : formatInr(v.min! * _factor);
    _maxField.text = v.max == null ? '' : formatInr(v.max! * _factor);
  }

  void _set(RangeValue v, {bool fromField = false}) {
    if (v == _monthly.value) return;
    _monthly.value = v;
    if (!fromField) _syncFields();
    widget.onChanged(
      v.min == null ? null : v.min! * 100,
      v.max == null ? null : v.max! * 100,
    );
  }

  void _typed({required bool isMin, required String text}) {
    final shown = int.tryParse(text.replaceAll(',', ''));
    final monthly = shown == null ? null : (shown / _factor).round();
    final v = _monthly.value;
    _set(
      isMin ? RangeValue(monthly, v.max) : RangeValue(v.min, monthly),
      fromField: true,
    );
  }

  List<RangePreset> _presets() {
    String s(int monthly) => '₹${shortInr(monthly * _factor)}';
    return [
      RangePreset('Under ${s(25000)}', const RangeValue(null, 25000)),
      RangePreset('${s(25000)}–${s(50000)}', const RangeValue(25000, 50000)),
      RangePreset('${s(50000)}–${s(100000)}', const RangeValue(50000, 100000)),
      RangePreset('${s(100000)}+', const RangeValue(100000, null)),
    ];
  }

  String _summary(RangeValue v) {
    String s(int monthly) => '₹${formatInr(monthly * _factor)}';
    if (v.isAny) return 'any salary';
    if (v.max == null) return '${s(v.min!)} or more ${_period.value.per}';
    if (v.min == null) return 'up to ${s(v.max!)} ${_period.value.per}';
    return '${s(v.min!)} – ${s(v.max!)} ${_period.value.per}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_monthly, _period]),
      builder: (context, _) {
        final v = _monthly.value;
        final f = _factor;
        return RangeFilterCard(
          children: [
            RangeCardHeader(
              icon: Icons.currency_rupee_rounded,
              title: 'Salary',
              onClear: v.isAny ? null : () => _set(RangeValue.any),
              trailing: _PeriodSwitch(period: _period),
            ),
            RangeSummary(lead: 'Pay of ', value: _summary(v)),
            RangeSliderRow(
              values: RangeValues(
                (v.min ?? 0).toDouble(),
                (v.max ?? _top).toDouble(),
              ),
              max: _top.toDouble(),
              divisions: _top ~/ _step,
              labels: [
                '₹0',
                '₹${shortInr(_top ~/ 2 * f)}',
                '₹${shortInr(_top * f)}+',
              ],
              onChanged: (r) => _set(
                RangeValue(
                  r.start <= 0 ? null : r.start.round(),
                  r.end >= _top ? null : r.end.round(),
                ),
              ),
            ),
            RangePresetChips(
              presets: _presets(),
              selected: v,
              onSelected: _set,
            ),
            MinMaxRow(
              min: _MoneyField(
                label: 'Minimum',
                hint: 'Any',
                controller: _minField,
                onChanged: (t) => _typed(isMin: true, text: t),
              ),
              max: _MoneyField(
                label: 'Maximum',
                hint: 'No limit',
                controller: _maxField,
                onChanged: (t) => _typed(isMin: false, text: t),
              ),
            ),
            if (v.isInverted)
              const RangeError('Minimum should be less than maximum.')
            else
              const _Hint('Leave empty to see jobs at any salary.'),
          ],
        );
      },
    );
  }
}

/// Small "Monthly | Yearly" switch in the card header.
class _PeriodSwitch extends StatelessWidget {
  const _PeriodSwitch({required this.period});

  final ValueNotifier<SalaryPeriod> period;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SalaryPeriod>(
      valueListenable: period,
      builder: (context, value, _) => SegmentedButton<SalaryPeriod>(
        segments: [
          for (final p in SalaryPeriod.values)
            ButtonSegment(value: p, label: Text(p.label)),
        ],
        selected: {value},
        showSelectedIcon: false,
        onSelectionChanged: (s) => period.value = s.first,
        style: const ButtonStyle(
          visualDensity: VisualDensity(horizontal: -3, vertical: -3),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}

/// Labelled rupee box with a number keypad and 1,00,000-style commas.
class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
        const _InrGroupingFormatter(),
      ],
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: '₹ ',
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _InrGroupingFormatter extends TextInputFormatter {
  const _InrGroupingFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(',', '');
    final n = int.tryParse(digits);
    final text = n == null ? '' : formatInr(n);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// 150000 → "1,50,000".
String formatInr(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  final last3 = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  return '${parts.join(',')},$last3';
}

/// 25000 → "25k", 150000 → "1.5L".
String shortInr(int n) {
  String trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  if (n >= 100000) return '${trim(n / 100000)}L';
  if (n >= 1000) return '${trim(n / 1000)}k';
  return '$n';
}

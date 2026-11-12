import 'package:curejobs/core/utils/date_time_utils.dart';
import 'package:equatable/equatable.dart';

/// One position in the candidate's work history.
class Experience extends Equatable {
  final String id;
  final String organizationName;
  final String jobTitle;

  /// Raw API value, e.g. `FULL_TIME`.
  final String? employmentType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool currentlyWorking;
  final String? location;
  final String? responsibilities;
  final int sortOrder;

  const Experience({
    required this.id,
    required this.organizationName,
    required this.jobTitle,
    this.employmentType,
    this.startDate,
    this.endDate,
    this.currentlyWorking = false,
    this.location,
    this.responsibilities,
    this.sortOrder = 0,
  });

  /// `FULL_TIME` → "Full time".
  String? get employmentTypeLabel {
    final type = employmentType;
    if (type == null || type.isEmpty) return null;
    final words = type.toLowerCase().replaceAll('_', ' ');
    return words[0].toUpperCase() + words.substring(1);
  }

  /// e.g. "Jan 2025 – Present".
  String get period {
    String fmt(DateTime d) => '${DateTimeUtils.months[d.month - 1]} ${d.year}';
    final start = startDate == null ? null : fmt(startDate!);
    final end = currentlyWorking
        ? 'Present'
        : (endDate == null ? null : fmt(endDate!));
    if (start != null && end != null) return '$start – $end';
    return start ?? end ?? '';
  }

  /// Months worked, counting both the start and end month; 0 when the
  /// start date is unknown.
  int monthsAt(DateTime now) {
    final start = startDate;
    if (start == null) return 0;
    final end = currentlyWorking ? now : (endDate ?? now);
    final months = (end.year - start.year) * 12 + end.month - start.month + 1;
    return months < 1 ? 1 : months;
  }

  /// e.g. "1 yr 10 mos"; empty when the start date is unknown.
  String durationAt(DateTime now) => formatMonths(monthsAt(now));

  /// Up to two letters from the organization name, e.g. "AT".
  String get initials {
    const skip = {'pvt', 'ltd', 'private', 'limited', 'the', 'of', 'and', '&'};
    final words = organizationName
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !skip.contains(w.toLowerCase()))
        .toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  /// Whole months between the end of [older] and the start of this one.
  /// 0 when they overlap, touch, or a date is missing.
  int gapAfter(Experience older) {
    final start = startDate;
    final end = older.currentlyWorking ? null : older.endDate;
    if (start == null || end == null) return 0;
    final gap = (start.year - end.year) * 12 + start.month - end.month - 1;
    return gap > 0 ? gap : 0;
  }

  /// 22 → "1 yr 10 mos"; 0 → "".
  static String formatMonths(int months) {
    if (months <= 0) return '';
    final y = months ~/ 12;
    final m = months % 12;
    return [
      if (y > 0) '$y yr${y > 1 ? 's' : ''}',
      if (m > 0) '$m mo${m > 1 ? 's' : ''}',
    ].join(' ');
  }

  @override
  List<Object?> get props => [
    id,
    organizationName,
    jobTitle,
    employmentType,
    startDate,
    endDate,
    currentlyWorking,
    location,
    responsibilities,
    sortOrder,
  ];
}

import 'package:flutter/material.dart';

import '../../domain/entities/job.dart';

/// Turns a [Job] into the short labels shown on a job card.
abstract final class JobFormatter {
  /// Logo tints for employers without a logo, picked per organisation.
  static const _accents = [
    Color(0xFF5145D9),
    Color(0xFF0F6E56),
    Color(0xFF854F0B),
    Color(0xFF993556),
    Color(0xFF185FA5),
  ];

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String employmentType(EmploymentType type) => switch (type) {
    EmploymentType.fullTime => 'Full-time',
    EmploymentType.partTime => 'Part-time',
    EmploymentType.contract => 'Contract',
    EmploymentType.temporary => 'Temporary',
    EmploymentType.internship => 'Internship',
    EmploymentType.freelance => 'Freelance',
    EmploymentType.other => 'Other',
  };

  /// "Fresher", "1–3 years", "2+ years", or null when unknown.
  static String? experience(Job job) {
    final min = job.experienceMinMonths;
    final max = job.experienceMaxMonths;
    if (min == null && max == null) return null;
    if ((min ?? 0) == 0 && (max ?? 0) == 0) return 'Fresher';

    String years(int months) {
      final value = months / 12;
      return value == value.roundToDouble()
          ? value.round().toString()
          : value.toStringAsFixed(1);
    }

    if (max == null) return '${years(min!)}+ years';
    if (min == null || min == 0) return 'Up to ${years(max)} years';
    if (min == max) return '${years(min)} years';
    return '${years(min)}–${years(max)} years';
  }

  /// City only, in title case. Falls back to the state.
  static String? location(Job job) {
    final place = [job.city, job.state]
        .whereType<String>()
        .map((part) => part.trim())
        .firstWhere((part) => part.isNotEmpty, orElse: () => '');
    if (place.isEmpty) return null;
    return place
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  /// "₹15k–50k", or null when the employer didn't share a salary.
  static String? salary(Job job) {
    if (!job.hasSalary) return null;
    final symbol = _currencySymbol(job.salaryCurrency);
    final min = job.salaryMinMinor;
    final max = job.salaryMaxMinor;

    if (min != null && max != null && min != max) {
      return '$symbol${_compact(min)}–${_compact(max)}';
    }
    return '$symbol${_compact(min ?? max!)}';
  }

  /// " /month" style suffix for [salary].
  static String salaryPeriod(SalaryPeriod? period) => switch (period) {
    SalaryPeriod.hourly => ' /hour',
    SalaryPeriod.daily => ' /day',
    SalaryPeriod.weekly => ' /week',
    SalaryPeriod.monthly => ' /month',
    SalaryPeriod.yearly => ' /year',
    null => '',
  };

  /// "Today", "Yesterday", "4 days ago", then "29 Sep".
  static String posted(DateTime? publishedAt, DateTime now) {
    if (publishedAt == null) return '';
    final local = publishedAt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final days = today.difference(day).inDays;

    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    final date = '${local.day} ${_months[local.month - 1]}';
    return local.year == now.year ? date : '$date ${local.year}';
  }

  /// Up to two letters from the employer name.
  static String initials(String name) {
    final words = name
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first
          .substring(0, words.first.length.clamp(0, 2))
          .toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  /// Same organisation always gets the same tint.
  static Color accent(String organizationId) {
    final hash = organizationId.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return _accents[hash % _accents.length];
  }

  static String _currencySymbol(String? code) => switch (code?.toUpperCase()) {
    'INR' || null => '₹',
    'USD' => r'$',
    'EUR' => '€',
    'GBP' => '£',
    final other => '$other ',
  };

  /// Minor units to "15k", "1.5L" style amounts.
  static String _compact(int minor) {
    final amount = minor / 100;
    String trim(double value) => value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);

    if (amount >= 100000) return '${trim(amount / 100000)}L';
    if (amount >= 1000) return '${trim(amount / 1000)}k';
    return trim(amount);
  }
}

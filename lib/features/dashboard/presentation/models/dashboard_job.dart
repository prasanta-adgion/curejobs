import 'package:flutter/material.dart';

/// UI-only model for a job card. Replace with a domain entity once the
/// jobs API is wired up.
class DashboardJob {
  const DashboardJob({
    required this.title,
    required this.employer,
    required this.initials,
    required this.tags,
    required this.salary,
    required this.postedLabel,
    this.accent = const Color(0xFF5145D9),
    this.isVerified = true,
    this.isSaved = false,
    this.isNew = false,
  });

  final String title;
  final String employer;
  final String initials;
  final List<String> tags;
  final String salary;
  final String postedLabel;
  final Color accent;
  final bool isVerified;
  final bool isSaved;
  final bool isNew;
}

/// Placeholder content shown until real data is available.
abstract final class DashboardSampleData {
  static const jobs = [
    DashboardJob(
      title: 'Staff nurse – ICU',
      employer: 'Apollo Hospitals',
      initials: 'AH',
      tags: ['Full-time', '1–3 years', 'Salt Lake'],
      salary: '₹28k–35k',
      postedLabel: '2 days ago',
    ),
    DashboardJob(
      title: 'Lab technician',
      employer: 'Medica Diagnostics',
      initials: 'MD',
      tags: ['Part-time', 'Fresher', 'Howrah'],
      salary: '₹18k–22k',
      postedLabel: 'New today',
      accent: Color(0xFF0F6E56),
      isSaved: true,
      isNew: true,
    ),
    DashboardJob(
      title: 'Pharmacist',
      employer: 'AMRI Hospitals',
      initials: 'AM',
      tags: ['Full-time', '3–5 years', 'Dhakuria'],
      salary: '₹25k–30k',
      postedLabel: '4 days ago',
      accent: Color(0xFF854F0B),
    ),
  ];
}

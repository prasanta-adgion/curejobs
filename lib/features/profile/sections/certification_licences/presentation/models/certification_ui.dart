import 'package:curejobs/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../domain/entities/certification.dart';

String _monthYear(DateTime d) =>
    '${DateTimeUtils.months[d.month - 1]} ${d.year}';

/// Colours and label for a status, shared by the row and the banner.
({String label, Color color, Color background}) certificationStatusStyle(
  CertificationStatus status,
  ColorScheme scheme,
) {
  return switch (status) {
    CertificationStatus.valid => (
      label: 'Valid',
      color: AppColors.success,
      background: AppColors.successLight,
    ),
    CertificationStatus.expiring => (
      label: 'Expiring',
      color: const Color(0xFFB45309),
      background: AppColors.warningLight,
    ),
    CertificationStatus.expired => (
      label: 'Expired',
      color: scheme.error,
      background: scheme.errorContainer,
    ),
    CertificationStatus.noExpiry => (
      label: 'No expiry',
      color: scheme.onSurfaceVariant,
      background: scheme.surfaceContainerHighest,
    ),
  };
}

extension CertificationUi on Certification {
  /// e.g. "Valid till Oct 2026", "Expires in 12 days", "Expired Oct 2025".
  String get validityLabel {
    final expiry = expiryDate;
    switch (status) {
      case CertificationStatus.noExpiry:
        final issued = issueDate;
        return issued == null ? 'No expiry' : 'Issued ${_monthYear(issued)}';
      case CertificationStatus.expired:
        return 'Expired ${_monthYear(expiry!)}';
      case CertificationStatus.expiring:
        final now = DateTime.now();
        final days = expiry!
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
        return switch (days) {
          0 => 'Expires today',
          1 => 'Expires tomorrow',
          _ => 'Expires in $days days',
        };
      case CertificationStatus.valid:
        return 'Valid till ${_monthYear(expiry!)}';
    }
  }
}

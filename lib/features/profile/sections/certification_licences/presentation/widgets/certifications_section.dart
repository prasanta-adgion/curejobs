import 'package:flutter/material.dart';

import '../../../../../../app/theme/app_colors.dart';
import '../../../../presentation/models/candidate_profile.dart';
import '../../../../shared/widgets/profile_section.dart';

/// Colours and label for a certificate status, shared by the row and banner.
({String label, Color color, Color background}) certificateStatusStyle(
  CertificateStatus status,
  ColorScheme scheme,
) {
  return switch (status) {
    CertificateStatus.verified => (
      label: 'Verified',
      color: AppColors.success,
      background: AppColors.successLight,
    ),
    CertificateStatus.expiring => (
      label: 'Expiring',
      color: const Color(0xFFB45309),
      background: AppColors.warningLight,
    ),
    CertificateStatus.pending => (
      label: 'Pending',
      color: scheme.onSurfaceVariant,
      background: scheme.surfaceContainerHighest,
    ),
  };
}

/// Certifications and licences block on the Qualifications tab.
class CertificationsSection extends StatelessWidget {
  const CertificationsSection({
    super.key,
    required this.certificates,
    this.onAdd,
    this.onTap,
  });

  final List<ProfileCertificate> certificates;
  final VoidCallback? onAdd;
  final ValueChanged<ProfileCertificate>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProfileSection(
      title: 'Certifications and licences',
      // Hidden until adding a certificate is built.
      action: onAdd == null
          ? null
          : SectionAction(label: 'Add', icon: Icons.add, onPressed: onAdd),
      child: certificates.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Add your nursing council licence and certificates like '
                'BLS so hospitals can verify you faster.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < certificates.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
                  _CertificateRow(
                    certificate: certificates[i],
                    onTap: onTap == null ? null : () => onTap!(certificates[i]),
                  ),
                ],
              ],
            ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.certificate, this.onTap});

  final ProfileCertificate certificate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = certificateStatusStyle(certificate.status, scheme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ProfileIconTile(
              icon: Icons.workspace_premium_outlined,
              size: 38,
              color: style.color,
              background: style.background,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${certificate.issuer} · ${certificate.validity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                style.label,
                style: theme.textTheme.labelSmall?.copyWith(color: style.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

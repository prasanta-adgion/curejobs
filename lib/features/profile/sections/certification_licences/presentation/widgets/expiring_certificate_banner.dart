import 'package:flutter/material.dart';

import '../../../../presentation/models/candidate_profile.dart';
import 'certifications_section.dart';

/// Amber banner at the top of Qualifications when a certificate or licence
/// is about to expire. Shows nothing when none are.
class ExpiringCertificateBanner extends StatelessWidget {
  const ExpiringCertificateBanner({
    super.key,
    required this.certificates,
    this.onUpdate,
  });

  final List<ProfileCertificate> certificates;
  final ValueChanged<ProfileCertificate>? onUpdate;

  @override
  Widget build(BuildContext context) {
    final expiring = certificates
        .where((c) => c.status == CertificateStatus.expiring)
        .toList();
    if (expiring.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final style = certificateStatusStyle(
      CertificateStatus.expiring,
      theme.colorScheme,
    );
    final first = expiring.first;
    final title = expiring.length == 1
        ? '${first.title} is expiring'
        : '${expiring.length} certificates are expiring';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: style.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: style.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${first.validity}. Upload the renewed certificate.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: style.color,
                    ),
                  ),
                ],
              ),
            ),
            // Hidden until updating a certificate is built.
            if (onUpdate != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => onUpdate!(first),
                style: FilledButton.styleFrom(
                  backgroundColor: style.color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Update'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/certification.dart';
import '../bloc/certifications_bloc.dart';
import '../models/certification_ui.dart';
import '../page/certification_form_page.dart';

/// Banner at the top of Qualifications when a certificate or licence is
/// expiring (amber) or has expired (red). Shows nothing otherwise. Reads
/// [CertificationsBloc] from the tree.
class ExpiringCertificateBanner extends StatelessWidget {
  const ExpiringCertificateBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CertificationsBloc, CertificationsState>(
      buildWhen: (prev, curr) => prev.items != curr.items,
      builder: (context, state) {
        final due = state.needingRenewal;
        if (due.isEmpty) return const SizedBox.shrink();
        return _Banner(due: due);
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.due});

  final List<Certification> due;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = due.first;
    final anyExpired = due.any((c) => c.status == CertificationStatus.expired);
    final style = certificationStatusStyle(
      anyExpired ? CertificationStatus.expired : CertificationStatus.expiring,
      theme.colorScheme,
    );
    final title = due.length == 1
        ? first.status == CertificationStatus.expired
              ? '${first.name} has expired'
              : '${first.name} is expiring'
        : '${due.length} certificates need renewal';

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
                    '${first.validityLabel}. Renew it to stay eligible.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: style.color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => openCertificationForm(context, first),
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
        ),
      ),
    );
  }
}

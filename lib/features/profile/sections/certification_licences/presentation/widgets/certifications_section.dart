import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/widgets/app_snackbar.dart';
import '../../../../shared/widgets/entry_more_menu.dart';
import '../../../../shared/widgets/profile_section.dart';
import '../../domain/entities/certification.dart';
import '../bloc/certifications_bloc.dart';
import '../models/certification_ui.dart';
import '../page/certification_form_page.dart';
import 'delete_certification_sheet.dart';

/// Certifications and licences block on the Qualifications tab. Reads
/// [CertificationsBloc] from the tree and opens the form itself.
class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  Future<void> _confirmDelete(BuildContext context, Certification c) async {
    final bloc = context.read<CertificationsBloc>();
    if (await showDeleteCertificationSheet(context, c)) {
      bloc.add(CertificationDeleted(c));
    }
  }

  void _onStateChanged(BuildContext context, CertificationsState state) {
    final failure = state.actionFailure;
    if (failure != null) {
      AppSnackbar.error(
        title: "Couldn't delete this certificate",
        message: failure.message,
      );
    } else if (state.deleted) {
      AppSnackbar.info(
        title: 'Certificate deleted',
        icon: Icons.delete_outline_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CertificationsBloc, CertificationsState>(
      listenWhen: (prev, curr) =>
          curr.deleted ||
          (curr.actionFailure != null &&
              prev.actionFailure != curr.actionFailure),
      listener: _onStateChanged,
      builder: (context, state) => ProfileSection(
        title: 'Certifications and licences',
        count: state.items.isEmpty ? null : state.items.length,
        action: SectionAction(
          label: 'Add',
          icon: Icons.add,
          onPressed: () => openCertificationForm(context),
        ),
        child: _Body(
          state: state,
          onEdit: (c) => openCertificationForm(context, c),
          onDelete: (c) => _confirmDelete(context, c),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final CertificationsState state;
  final ValueChanged<Certification> onEdit;
  final ValueChanged<Certification> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final items = state.items;

    if (state.isLoading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (state.status == CertificationsStatus.failure && items.isEmpty) {
      return Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: scheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.failure?.message ?? "Couldn't load your certificates.",
              style: muted,
            ),
          ),
          TextButton(
            onPressed: () => context.read<CertificationsBloc>().add(
              const CertificationsRequested(),
            ),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Add your nursing council licence and certificates like '
          'BLS so hospitals can verify you faster.',
          style: muted,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) Divider(height: 1, color: scheme.outlineVariant),
          _CertificateRow(
            certificate: items[i],
            deleting: state.isDeleting(items[i]),
            onEdit: () => onEdit(items[i]),
            onDelete: () => onDelete(items[i]),
          ),
        ],
      ],
    );
  }
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({
    required this.certificate,
    required this.deleting,
    required this.onEdit,
    required this.onDelete,
  });

  final Certification certificate;
  final bool deleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = certificationStatusStyle(certificate.status, scheme);
    final details = [
      if (certificate.issuingOrganization.isNotEmpty)
        certificate.issuingOrganization,
      certificate.validityLabel,
    ].join(' · ');
    final credentialId = certificate.credentialId;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: deleting ? 0.5 : 1,
      child: InkWell(
        onTap: deleting ? null : onEdit,
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
                      certificate.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      details,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (credentialId != null && credentialId.isNotEmpty)
                      Text(
                        'ID: $credentialId',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  style.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: style.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              SizedBox.square(
                dimension: 32,
                child: deleting
                    ? Center(
                        child: SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        ),
                      )
                    : EntryMoreMenu(
                        title: certificate.name,
                        subtitle: certificate.issuingOrganization,
                        editHint: 'Name, dates, credential',
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

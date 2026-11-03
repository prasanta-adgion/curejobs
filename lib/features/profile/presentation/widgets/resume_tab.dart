import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../models/candidate_profile.dart';
import 'profile_section.dart';

/// CV preview with replace and view actions, certificates and a tip.
class ResumeTab extends StatelessWidget {
  const ResumeTab({
    super.key,
    required this.profile,
    this.onUploadCv,
    this.onViewCv,
    this.onAddCertificate,
  });

  final CandidateProfile profile;
  final VoidCallback? onUploadCv;
  final VoidCallback? onViewCv;
  final VoidCallback? onAddCertificate;

  @override
  Widget build(BuildContext context) {
    final cv = profile.cv;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ProfileSection(
          title: 'Your CV',
          showDivider: false,
          child: cv == null
              ? _EmptyCv(onUpload: onUploadCv)
              : _CvCard(cv: cv, onReplace: onUploadCv, onView: onViewCv),
        ),
        ProfileSection(
          title: 'Certificates',
          action: SectionAction(
            label: 'Add',
            icon: Icons.add,
            onPressed: onAddCertificate,
          ),
          child: Column(
            children: [
              for (var i = 0; i < profile.certificates.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                _CertificateRow(certificate: profile.certificates[i]),
              ],
            ],
          ),
        ),
        if (profile.tip != null)
          ProfileSection(
            title: 'Tips',
            child: _Tip(text: profile.tip!),
          ),
      ],
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({required this.cv, this.onReplace, this.onView});

  final ProfileCv cv;
  final VoidCallback? onReplace;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CvThumbnail(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.fileName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${cv.sizeLabel} · ${cv.pages} '
                    '${cv.pages == 1 ? 'page' : 'pages'}',
                    style: muted,
                  ),
                  Text(cv.updatedLabel, style: muted),
                  if (cv.isVisibleToRecruiters) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Visible to recruiters',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: FilledButton.icon(
                  onPressed: onReplace,
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: const Text('Replace'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Stylised first page of the CV, so the file reads as a document at a glance.
class _CvThumbnail extends StatelessWidget {
  const _CvThumbnail();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget line(double? width, Color color, {double height = 3}) => Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    return Container(
      width: 92,
      height: 122,
      padding: const EdgeInsets.fromLTRB(9, 10, 9, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(40, AppColors.logoNavy, height: 5),
          line(56, AppColors.lightTextDisabled),
          const SizedBox(height: 5),
          line(30, AppColors.primary),
          line(null, AppColors.lightBorder),
          line(null, AppColors.lightBorder),
          line(50, AppColors.lightBorder),
          const SizedBox(height: 5),
          line(30, AppColors.primary),
          line(null, AppColors.lightBorder),
          line(null, AppColors.lightBorder),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'PDF',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCv extends StatelessWidget {
  const _EmptyCv({this.onUpload});

  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfileIconTile(
                icon: Icons.cloud_upload_outlined,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Upload your CV',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'PDF, DOC or DOCX · up to 5 MB',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.certificate});

  final ProfileCertificate certificate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final (label, color, background) = switch (certificate.status) {
      CertificateStatus.verified => (
        'Verified',
        AppColors.success,
        AppColors.successLight,
      ),
      CertificateStatus.expiring => (
        'Expiring',
        const Color(0xFFB45309),
        AppColors.warningLight,
      ),
      CertificateStatus.pending => (
        'Pending',
        scheme.onSurfaceVariant,
        scheme.surfaceContainerHighest,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ProfileIconTile(
            icon: Icons.workspace_premium_outlined,
            size: 38,
            color: color,
            background: background,
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
              color: background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

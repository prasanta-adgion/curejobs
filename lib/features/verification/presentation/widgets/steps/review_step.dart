import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';
import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';
import 'package:curejobs/features/verification/domain/entities/verification_request_detail.dart';

import '../common/rejection_note.dart';
import '../common/verification_hero.dart';
import '../common/verification_info_row.dart';
import '../common/verification_scaffold.dart';
import '../documents/uploaded_document_list.dart';

/// Step 3 — documents were sent and are waiting for the admin. Shows the
/// "Under review" status, each sent document with its status and note, and
/// the timeline.
class ReviewStep extends StatelessWidget {
  const ReviewStep({
    super.key,
    required this.types,
    required this.documents,
    required this.rejectionReason,
    required this.fileNames,
    required this.deletingIds,
    required this.onView,
    required this.onDelete,
    this.reviewedAt,
    this.submittedAt,
    this.expectedBy,
  });

  final List<VerificationDocumentType> types;
  final List<VerificationDocument> documents;
  final String? rejectionReason;
  final Map<String, String> fileNames;
  final Set<String> deletingIds;
  final ValueChanged<VerificationDocument> onView;
  final ValueChanged<VerificationDocument> onDelete;

  /// Formatted dates; each row hides when null.
  final String? reviewedAt;
  final String? submittedAt;
  final String? expectedBy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = isDark ? AppColors.warning : const Color(0xFFB45309);
    final amberBg = isDark
        ? AppColors.warning.withValues(alpha: 0.15)
        : AppColors.warningLight;

    return VerificationSections(
      children: [
        ProfileSection(
          title: 'Status',
          child: VerificationHero(
            icon: Icons.hourglass_top_rounded,
            color: amber,
            background: amberBg,
            title: 'Under review',
            subtitle: "Usually within 2 working days. We'll notify you.",
          ),
        ),
        VerificationRejectionNote(
          documents: documents,
          types: types,
          reason: rejectionReason,
        ),
        // From `GET verifications/{id}`: each document with its status and
        // the reviewer's note.
        if (documents.isNotEmpty)
          ProfileSection(
            title: 'Submitted documents',
            child: UploadedDocumentList(
              documents: documents,
              types: types,
              fileNames: fileNames,
              deletingIds: deletingIds,
              onView: onView,
              onDelete: onDelete,
            ),
          ),
        if (reviewedAt != null)
          ProfileSection(
            title: 'Reviewed',
            child: VerificationInfoRow(
              label: 'Reviewed on',
              value: reviewedAt!,
              showDivider: false,
            ),
          ),
        if (submittedAt != null || expectedBy != null)
          ProfileSection(
            title: 'Timeline',
            child: Column(
              children: [
                if (submittedAt != null)
                  VerificationInfoRow(
                    label: 'Submitted',
                    value: submittedAt!,
                    showDivider: expectedBy != null,
                  ),
                if (expectedBy != null)
                  VerificationInfoRow(
                    label: 'Expected by',
                    value: expectedBy!,
                    showDivider: false,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

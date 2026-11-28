import 'package:flutter/material.dart';

import 'package:curejobs/features/profile/shared/widgets/profile_section.dart';
import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';
import 'package:curejobs/features/verification/domain/entities/verification_request_detail.dart';

import '../common/plan_active_note.dart';
import '../common/privacy_section.dart';
import '../common/rejection_note.dart';
import '../common/verification_scaffold.dart';
import '../documents/add_document_form.dart';
import '../documents/added_document.dart';
import '../documents/document_checklist.dart';
import '../documents/uploaded_document_list.dart';

/// Step 2b — the request exists and document types are loaded: checklist,
/// documents attached so far, and the upload form. "Submit for review" is
/// in the page's bottom bar.
///
/// Only one active document is allowed, so the form hides once one is
/// attached; a rejected one doesn't count, so the form comes back.
class DocumentsStep extends StatelessWidget {
  const DocumentsStep({
    super.key,
    required this.planName,
    required this.planActiveUntil,
    required this.types,
    required this.documents,
    required this.isDraft,
    required this.rejectionReason,
    required this.fileNames,
    required this.deletingIds,
    required this.onView,
    required this.onDelete,
    required this.onUpload,
  });

  final String? planName;
  final String? planActiveUntil;
  final List<VerificationDocumentType> types;

  /// Every document attached to the request, incl. rejected ones.
  final List<VerificationDocument> documents;
  final bool isDraft;
  final String? rejectionReason;
  final Map<String, String> fileNames;
  final Set<String> deletingIds;
  final ValueChanged<VerificationDocument> onView;
  final ValueChanged<VerificationDocument> onDelete;
  final Future<bool> Function(AddedDocument document) onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = documents.where((d) => !d.needsReplacing);
    final hasActiveDocument = active.isNotEmpty;

    return VerificationSections(
      children: [
        PlanActiveNote(planName: planName, activeUntil: planActiveUntil),
        VerificationRejectionNote(
          documents: documents,
          types: types,
          reason: rejectionReason,
        ),
        if (types.isNotEmpty)
          ProfileSection(
            title: 'What to upload',
            child: DocumentChecklist(
              types: types,
              doneTypeIds: {for (final d in active) d.documentTypeId},
            ),
          ),
        // Every attached document; rejected ones get a delete button.
        if (documents.isNotEmpty)
          ProfileSection(
            title: 'Uploaded document',
            child: UploadedDocumentList(
              documents: documents,
              types: types,
              isDraft: isDraft,
              fileNames: fileNames,
              deletingIds: deletingIds,
              onView: onView,
              onDelete: onDelete,
            ),
          ),
        if (!hasActiveDocument)
          ProfileSection(
            title: documents.isEmpty
                ? 'Upload a document'
                : 'Upload a new document',
            child: types.isEmpty
                ? Text(
                    'No document types are available right now.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                : AddDocumentForm(types: types, onUpload: onUpload),
          ),
        const VerificationPrivacySection(),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';
import 'package:curejobs/features/verification/domain/entities/verification_request_detail.dart';

import 'uploaded_document_card.dart';

/// Documents attached to the request, one [UploadedDocumentCard] each.
///
/// Delete shows on every document except one in review (sent and waiting
/// for the admin). While the request is a draft ([isDraft]) nothing is in
/// review.
class UploadedDocumentList extends StatelessWidget {
  const UploadedDocumentList({
    super.key,
    required this.documents,
    required this.types,
    required this.onView,
    this.isDraft = false,
    this.fileNames = const {},
    this.deletingIds = const {},
    this.onDelete,
  });

  final List<VerificationDocument> documents;

  /// To show each document's type name.
  final List<VerificationDocumentType> types;

  /// The request hasn't been sent for review yet.
  final bool isDraft;

  /// Local file names by `fileId`, for documents uploaded in this session.
  final Map<String, String> fileNames;

  /// Ids of documents being deleted; they show a spinner.
  final Set<String> deletingIds;

  final ValueChanged<VerificationDocument> onView;

  /// Null hides every delete button.
  final ValueChanged<VerificationDocument>? onDelete;

  @override
  Widget build(BuildContext context) {
    final typesById = {for (final t in types) t.id: t};

    return Column(
      children: [
        for (final (i, doc) in documents.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
            child: UploadedDocumentCard(
              document: doc,
              typeName: typesById[doc.documentTypeId]?.name ?? 'Document',
              fileName: fileNames[doc.fileId],
              isDraft: isDraft,
              deleting: deletingIds.contains(doc.id),
              onView: () => onView(doc),
              // onDelete: onDelete != null && !_isInReview(doc)
              //     ? () => onDelete!(doc)
              //     : null,
              onDelete: onDelete == null ? null : () => onDelete!(doc),
            ),
          ),
      ],
    );
  }
}

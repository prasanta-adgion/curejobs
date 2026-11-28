import 'package:flutter/material.dart';

import 'package:curejobs/app/theme/app_colors.dart';
import 'package:curejobs/core/utils/extensions/theme_extensions.dart';
import 'package:curejobs/features/verification/domain/entities/verification_eligibility.dart';
import 'package:curejobs/features/verification/domain/entities/verification_request_detail.dart';

import 'document_file_icon.dart';

/// One attached document: file icon, type name, status and file name, with
/// View and Delete icon buttons, and the reviewer's note underneath.
/// Rejected documents get a red tint so they stand out for replacing.
class UploadedDocumentCard extends StatelessWidget {
  const UploadedDocumentCard({
    super.key,
    required this.document,
    required this.typeName,
    required this.fileName,
    required this.isDraft,
    required this.deleting,
    required this.onView,
    required this.onDelete,
  });

  final VerificationDocument document;
  final String typeName;

  /// Known only for files uploaded in this session.
  final String? fileName;
  final bool isDraft;
  final bool deleting;
  final VoidCallback onView;

  /// Null when this document can't be deleted.
  final VoidCallback? onDelete;

  /// Label and colour for the status. While the request is a draft, a
  /// document that isn't rejected reads "Uploaded" whatever its own status.
  (String, Color) _status(BuildContext context) {
    final error = context.colors.error;
    const success = AppColors.success;
    const amber = Color(0xFFB45309);
    return switch (document.status) {
      VerificationDocumentStatus.rejected => ('Rejected', error),
      VerificationDocumentStatus.needsChanges => ('Needs changes', error),
      VerificationDocumentStatus.revoked => ('Revoked', error),
      _ when isDraft => ('Uploaded', success),
      VerificationDocumentStatus.approved => ('Approved', success),
      VerificationDocumentStatus.pending => ('In review', amber),
      VerificationDocumentStatus.notSubmitted => ('Uploaded', success),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rejected = document.needsReplacing;
    final (statusLabel, statusColor) = _status(context);
    final note = document.reviewNote?.trim();
    final name = fileName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          decoration: BoxDecoration(
            color: rejected
                ? colors.errorContainer.withValues(alpha: 0.25)
                : colors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: rejected
                  ? colors.error.withValues(alpha: 0.35)
                  : colors.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              DocumentFileIcon(fileName: name, rejected: rejected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (name != null) TextSpan(text: '  ·  $name'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'View',
                visualDensity: VisualDensity.compact,
                onPressed: onView,
                icon: Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (deleting)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (onDelete != null)
                IconButton(
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: colors.error,
                  ),
                ),
            ],
          ),
        ),
        // The reviewer's note, as one small line under the card.
        if (note != null && note.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 13,
                  color: colors.error,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    note,
                    style: context.textStyles.bodySmall?.copyWith(
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:curejobs/features/verification/domain/entities/verification_document_type.dart';
import 'package:curejobs/features/verification/domain/entities/verification_eligibility.dart';
import 'package:curejobs/features/verification/domain/entities/verification_request_detail.dart';

import 'verification_note.dart';

/// Red note naming each rejected document and why, plus the request's
/// overall rejection reason. Renders nothing when nothing was rejected.
///
/// Why: the admin rejects per document, so the user needs to know which
/// one to replace and what was wrong with it.
class VerificationRejectionNote extends StatelessWidget {
  const VerificationRejectionNote({
    super.key,
    required this.documents,
    required this.types,
    this.reason,
  });

  final List<VerificationDocument> documents;

  /// To name each rejected document.
  final List<VerificationDocumentType> types;

  /// The request's own rejection reason, if any.
  final String? reason;

  /// e.g. "Medical licence was rejected: photo is blurry".
  static String _rejectedLine(String name, VerificationDocument d) {
    final verb = switch (d.status) {
      VerificationDocumentStatus.needsChanges => 'needs changes',
      VerificationDocumentStatus.revoked => 'was revoked',
      _ => 'was rejected',
    };
    final note = d.reviewNote?.trim();
    return note == null || note.isEmpty ? '$name $verb' : '$name $verb: $note';
  }

  @override
  Widget build(BuildContext context) {
    final rejected = documents.where((d) => d.needsReplacing).toList();
    final reason = this.reason?.trim();
    final hasReason = reason != null && reason.isNotEmpty;
    if (rejected.isEmpty && !hasReason) return const SizedBox.shrink();

    final typeNames = {for (final t in types) t.id: t.name};
    final lines = [
      for (final d in rejected)
        _rejectedLine(typeNames[d.documentTypeId] ?? 'Document', d),
      if (hasReason) 'Reason: $reason',
    ];
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: VerificationNote(
        icon: Icons.error_outline_rounded,
        text: lines.join('\n'),
        color: scheme.onErrorContainer,
        background: scheme.errorContainer,
      ),
    );
  }
}

part of 'verification_bloc.dart';

sealed class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Loads eligibility, the user's verification and the request detail, which
/// together decide the step. Sent once the plan is known, and again whenever
/// the step may have changed (after upgrading, deleting or submitting).
final class VerificationLoadRequested extends VerificationEvent {
  const VerificationLoadRequested();
}

/// "Start verification": starts a request (unless one exists) and loads
/// the document types.
final class VerificationStartRequested extends VerificationEvent {
  const VerificationStartRequested();
}

/// "Upload document": attaches an already-uploaded file to the request.
///
/// [result] completes with whether it worked, so the upload form knows
/// whether to clear itself.
final class VerificationDocumentAttached extends VerificationEvent {
  const VerificationDocumentAttached(this.document, this.result);

  final AddedDocument document;
  final Completer<bool> result;

  @override
  List<Object?> get props => [document.fileId];
}

/// Deletes an attached document. The page asks the user to confirm first.
final class VerificationDocumentDeleted extends VerificationEvent {
  const VerificationDocumentDeleted(this.document);

  final VerificationDocument document;

  @override
  List<Object?> get props => [document.id];
}

/// "Submit for review".
final class VerificationSubmitRequested extends VerificationEvent {
  const VerificationSubmitRequested();
}

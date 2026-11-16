part of 'resume_viewer_bloc.dart';

sealed class ResumeViewerEvent extends Equatable {
  const ResumeViewerEvent();

  @override
  List<Object?> get props => [];
}

/// Fetches (or re-fetches) the signed URL for the resume's PDF.
final class ResumeViewerUrlRequested extends ResumeViewerEvent {
  const ResumeViewerUrlRequested(this.fileId);

  final String fileId;

  @override
  List<Object?> get props => [fileId];
}

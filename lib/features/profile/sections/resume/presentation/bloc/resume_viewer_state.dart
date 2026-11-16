part of 'resume_viewer_bloc.dart';

enum ResumeViewerStatus { initial, loading, ready, failure }

class ResumeViewerState extends Equatable {
  final ResumeViewerStatus status;

  /// Signed PDF URL, set when [status] is ready.
  final String? url;

  /// Set when fetching the URL fails.
  final Failure? failure;

  const ResumeViewerState({
    this.status = ResumeViewerStatus.initial,
    this.url,
    this.failure,
  });

  @override
  List<Object?> get props => [status, url, failure];
}

part of 'resume_bloc.dart';

sealed class ResumeEvent extends Equatable {
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

/// Loads or reloads the resumes.
final class ResumesRequested extends ResumeEvent {
  const ResumesRequested();
}

/// Asks for a signed URL to download [resume]'s PDF.
final class ResumeDownloadRequested extends ResumeEvent {
  const ResumeDownloadRequested(this.resume);

  final Resume resume;

  @override
  List<Object?> get props => [resume];
}

/// Makes [resume] the default CV.
final class ResumeSetDefaultRequested extends ResumeEvent {
  const ResumeSetDefaultRequested(this.resume);

  final Resume resume;

  @override
  List<Object?> get props => [resume];
}

/// Deletes [resume]. Confirm with the user before sending.
final class ResumeDeleteRequested extends ResumeEvent {
  const ResumeDeleteRequested(this.resume);

  final Resume resume;

  @override
  List<Object?> get props => [resume];
}

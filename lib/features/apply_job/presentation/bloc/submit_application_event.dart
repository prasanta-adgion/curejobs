part of 'submit_application_bloc.dart';

sealed class SubmitApplicationEvent extends Equatable {
  const SubmitApplicationEvent();

  @override
  List<Object?> get props => [];
}

/// Sends the application for [jobId] with [resumeId] and [answers].
final class SubmitApplicationRequested extends SubmitApplicationEvent {
  const SubmitApplicationRequested({
    required this.jobId,
    required this.resumeId,
    required this.answers,
  });

  final String jobId;
  final String resumeId;
  final List<ScreeningAnswer> answers;

  @override
  List<Object?> get props => [jobId, resumeId, answers];
}

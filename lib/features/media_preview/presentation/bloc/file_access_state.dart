part of 'file_access_cubit.dart';

enum FileAccessStatus { initial, loading, ready, failure }

class FileAccessState extends Equatable {
  final FileAccessStatus status;

  /// Set when [status] is ready.
  final String? url;

  /// Set when [status] is failure.
  final Failure? failure;

  const FileAccessState({
    this.status = FileAccessStatus.initial,
    this.url,
    this.failure,
  });

  bool get isLoading =>
      status == FileAccessStatus.initial || status == FileAccessStatus.loading;

  @override
  List<Object?> get props => [status, url, failure];
}

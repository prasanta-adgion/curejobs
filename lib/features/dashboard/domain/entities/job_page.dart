import 'package:equatable/equatable.dart';

import 'job.dart';

/// One page of jobs plus what's needed to ask for the next one.
class JobPage extends Equatable {
  final List<Job> jobs;
  final int page;
  final int total;
  final bool hasMore;

  const JobPage({
    required this.jobs,
    required this.page,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [jobs, page, total, hasMore];
}

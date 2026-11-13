/// Which list of jobs to load. Both return the same response shape.
enum JobFeed {
  /// Every published job (`api/v1/jobs`).
  all,

  /// Jobs picked for the candidate (`api/v1/jobs/recommended`).
  recommended,
}

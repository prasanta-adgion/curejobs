class AppConstants {
  AppConstants._();

  // Pagination
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Search behavior
  static const Duration searchDebounce = Duration(milliseconds: 400);

  static const int minSearchLength = 2;

  // Form validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;

  static const int maxNameLength = 100;
  static const int maxBioLength = 500;

  // Job listing behavior
  static const int featuredJobsLimit = 10;
  static const int recentJobsLimit = 10;

  // File upload limits (client-side)
  static const int maxResumeSizeBytes = 5 * 1024 * 1024;

  static const List<String> allowedResumeExtensions = ['pdf', 'doc', 'docx'];
}

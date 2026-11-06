class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'api/v1/auth/login';
  static const String refresh = 'api/v1/auth/refresh';
  static const String candidateProfile = 'api/v1/candidates/me';
  static const String categories = 'api/v1/categories';
  static const String jobs = 'api/v1/jobs';
  static const String unreadNotifications = 'api/v1/notifications/unread-count';
  static const String logout = 'api/v1/auth/logout';
  static String specializationsByCategory({required String categoryId}) =>
      'api/v1/categories/$categoryId/specializations';

  //file upload
  static const String uploadFile = 'api/v1/files/upload-url';
  static String uploadFileComplete({required String fileId}) =>
      'api/v1/files/$fileId/complete';

  static String getFileAccess({required String fileId}) =>
      'api/v1/files/$fileId/access';
}

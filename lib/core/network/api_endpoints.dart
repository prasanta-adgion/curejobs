class ApiEndpoints {
  ApiEndpoints._();

  static const String login = 'api/v1/auth/login';
  static const String register = 'api/v1/auth/register';
  static const String verifyOtp = 'api/v1/auth/email/verify';
  static const String resendVerificationCode = 'api/v1/auth/email/resend';

  static const String refresh = 'api/v1/auth/refresh';
  static const String candidateProfile = 'api/v1/candidates/me';
  static const String categories = 'api/v1/categories';
  static const String jobs = 'api/v1/jobs';
  static const String jobsRecommended = 'api/v1/jobs/recommended';
  static const String unreadNotifications = 'api/v1/notifications/unread-count';
  static const String logout = 'api/v1/auth/logout';
  static String specializationsByCategory({required String categoryId}) =>
      'api/v1/categories/$categoryId/specializations';

  static const String locationSuggestions = 'api/v1/locations/suggestions';

  //file upload
  static const String uploadFile = 'api/v1/files/upload-url';
  static String uploadFileComplete({required String fileId}) =>
      'api/v1/files/$fileId/complete';

  static String getFileAccess({required String fileId}) =>
      'api/v1/files/$fileId/access';

  //profile part
  static const String candidateEducation = 'api/v1/candidates/me/education';
  static String candidateEducationById({required String id}) =>
      '$candidateEducation/$id';
  static const String candidateExperience = 'api/v1/candidates/me/experience';
  static String candidateExperienceById({required String id}) =>
      '$candidateExperience/$id';

  static const String skills = 'api/v1/candidates/me/skills';
  static String skillById({required String id}) => '$skills/$id';

  static const String languages = 'api/v1/candidates/me/languages';
  static String languageById({required String id}) => '$languages/$id';

  static const String certificates = 'api/v1/candidates/me/certifications';
  static String certificateById({required String id}) => '$certificates/$id';

  static const String allAppliedApplications = 'api/v1/applications/me';
  static String appliedApplicationById({required String appliedJobId}) =>
      'api/v1/applications/me/$appliedJobId';

  static const String applicationAppliedStatus =
      "api/v1/applications/me/statuses"; //check application applied status

  static String withdrawApplication({required String appliedJobId}) =>
      'api/v1/applications/me/$appliedJobId/withdraw';

  static const String resumes = 'api/v1/resumes';

  static String setDefaultResume({required String cvId}) =>
      'api/v1/resumes/$cvId/default';

  static String deleteResume({required String cvId}) => 'api/v1/resumes/$cvId';

  //job view analytics
  static String jobViewAnalytics({required String id}) =>
      'api/v1/jobs/$id/analytics/view';
  static String jobImpressionAnalytics({required String id}) =>
      'api/v1/jobs/$id/analytics/impression';
  static String applyStartAnalytics({required String jobId}) =>
      'api/v1/jobs/$jobId/analytics/apply-start';

  //job search
  static const String jobSearchSuggestions = 'api/v1/jobs/suggestions';

  static String jobApplicationEligibility({required String id}) =>
      'api/v1/jobs/$id/application-eligibility';

  static String jobApplicationSubmit({required String jobId}) =>
      'api/v1/jobs/$jobId/applications';

  //plans
  static const String packages = 'api/v1/packages';
  static const String currentPlan = 'api/v1/subscriptions/me';

  static const String subscribeToPlan = 'api/v1/payments/me';
  static const String planHistory = 'api/v1/subscriptions/me/history';

  //roazerpay plan subscription buy
  static const String purchases = 'api/v1/purchases';
  static String razorpaySubscription({required String purchaseId}) =>
      'api/v1/purchases/$purchaseId/payments/razorpay/subscription';

  static const String verifyRazorpayPayment = 'api/v1/payments/razorpay/verify';

  static const String selectPlan = "api/v1/subscriptions/select";

  //dashboard, notifications, read unread notifications, count of unread notifications
  static const String unreadNotificationCount =
      'api/v1/notifications/unread-count';

  static const String allNotifications = 'api/v1/notifications';

  static String markNotificationsRead({required String notificationId}) =>
      'api/v1/notifications/$notificationId/read';

  static const String markAllNotificationsRead =
      'api/v1/notifications/read-all';

  static const String jobAlertPreferences =
      'api/v1/candidates/me/job-alert-preferences';

  static String organizationById({required String slug}) =>
      'api/v1/public/organizations/$slug';

  //profile visibility
  static const String matchPrivacy = 'api/v1/candidates/me/match-privacy';
  static const String profileActivity = 'api/v1/candidates/me/profile-activity';

  //candidate verification

  static const String documentTypes = 'api/v1/verifications/document-types';

  static String documentTypeById({required String id}) =>
      'api/v1/verifications/$id/documents';

  static const String verificationEligibility =
      'api/v1/verifications/eligibility';

  static const String candidateVerification = 'api/v1/verifications/me';

  static String rejectionReason({required String id}) =>
      'api/v1/verifications/$id';
}

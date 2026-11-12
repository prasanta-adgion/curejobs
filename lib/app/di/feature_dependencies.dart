import 'package:get_it/get_it.dart';

import '../../features/auth/login/di/login_dependencies.dart';
import '../../features/auth/otp_verification/di/otp_verification_dependencies.dart';
import '../../features/auth/registration/di/registration_dependencies.dart';
import '../../features/category/di/category_dependencies.dart';
import '../../features/create_account/di/create_account_dependencies.dart';
import '../../features/dashboard/di/dashboard_dependencies.dart';
import '../../features/media_preview/di/media_preview_dependencies.dart';
import '../../features/profile/di/profile_dependencies.dart';
import '../../features/profile/sections/education/di/education_dependencies.dart';
import '../../features/profile/sections/experience/di/experience_dependencies.dart';
import '../../features/profile/sections/skill/di/skill_dependencies.dart';
import '../../features/profile/sections/language/di/language_dependencies.dart';
import '../../features/specialization/di/specialization_dependencies.dart';

void registerFeatureDependencies(GetIt sl) {
  registerLoginDependencies(sl);
  registerRegistrationDependencies(sl);
  registerOtpVerificationDependencies(sl);
  registerProfileDependencies(sl);
  registerEducationDependencies(sl);
  registerExperienceDependencies(sl);
  registerSkillDependencies(sl);
  registerLanguageDependencies(sl);
  registerDashboardDependencies(sl);
  registerCategoryDependencies(sl);
  registerSpecializationDependencies(sl);
  registerMediaPreviewDependencies(sl);
  registerCreateAccountDependencies(sl);
}

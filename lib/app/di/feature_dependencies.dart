import 'package:get_it/get_it.dart';

import '../../features/auth/login/di/login_dependencies.dart';
import '../../features/category/di/category_dependencies.dart';
import '../../features/dashboard/di/dashboard_dependencies.dart';
import '../../features/media_preview/di/media_preview_dependencies.dart';
import '../../features/profile/di/profile_dependencies.dart';
import '../../features/specialization/di/specialization_dependencies.dart';

void registerFeatureDependencies(GetIt sl) {
  registerLoginDependencies(sl);
  registerProfileDependencies(sl);
  registerDashboardDependencies(sl);
  registerCategoryDependencies(sl);
  registerSpecializationDependencies(sl);
  registerMediaPreviewDependencies(sl);
}

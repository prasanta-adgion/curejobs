import 'package:get_it/get_it.dart';

import '../../features/auth/login/di/login_dependencies.dart';
import '../../features/dashboard/di/dashboard_dependencies.dart';
import '../../features/profile/di/profile_dependencies.dart';

void registerFeatureDependencies(GetIt sl) {
  registerLoginDependencies(sl);
  registerProfileDependencies(sl);
  registerDashboardDependencies(sl);
}
